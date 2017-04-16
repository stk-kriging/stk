/*****************************************************************************
 *                                                                           *
 *                  Small (Matlab/Octave) Toolbox for Kriging                *
 *                                                                           *
 * Copyright Notice                                                          *
 *                                                                           *
 *    Copyright (C) 2015-2017 CentraleSupelec                                *
 *                                                                           *
 *    Author:  Julien Bect  <julien.bect@centralesupelec.fr>                 *
 *                                                                           *
 *    Based on the file wfg.c from WFG 1.10 by Lyndon While, Lucas           *
 *    Bradstreet, Luigi Barone, released under the GPLv2+ licence. The       *
 *    original copyright notice is:                                          *
 *                                                                           *
 *       Copyright (C) 2010 Lyndon While, Lucas Bradstreet                   *
 *                                                                           *
 * Copying Permission Statement                                              *
 *                                                                           *
 *    This file is part of                                                   *
 *                                                                           *
 *            STK: a Small (Matlab/Octave) Toolbox for Kriging               *
 *               (http://sourceforge.net/projects/kriging)                   *
 *                                                                           *
 *    STK is free software: you can redistribute it and/or modify it under   *
 *    the terms of the GNU General Public License as published by the Free   *
 *    Software Foundation,  either version 3  of the License, or  (at your   *
 *    option) any later version.                                             *
 *                                                                           *
 *    STK is distributed  in the hope that it will  be useful, but WITHOUT   *
 *    ANY WARRANTY;  without even the implied  warranty of MERCHANTABILITY   *
 *    or FITNESS  FOR A  PARTICULAR PURPOSE.  See  the GNU  General Public   *
 *    License for more details.                                              *
 *                                                                           *
 *    You should  have received a copy  of the GNU  General Public License   *
 *    along with STK.  If not, see <http://www.gnu.org/licenses/>.           *
 *                                                                           *
 ****************************************************************************/

/* TODO: find out which of these includes are *REALLY* necessary */

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "mex.h"
#include "wfg.h"

double hv (FRONT*);
/* and the RLIST-variant of hv: */
void Rlist_hv (FRONT* ps, RLIST* Rlist, int sign);

#define BEATS(x,y)   (x > y)
#define WORSE(x,y)   (BEATS(y,x) ? (x) : (y))

FRONT *fs = NULL;  /* memory management stuff                      */
int fr = 0;        /* current depth                                */
int safe = 0;      /* the number of points that don't need sorting */


int greater (const void *v1, const void *v2)
/* this sorts points worsening in the last objective */
{
    int i;
    POINT p = *(POINT*)v1;
    POINT q = *(POINT*)v2;
    int n = p.n; /* assume that p and q have the same size */

    for (i = n - 1; i >= 0; i--)
        if BEATS(p.objectives[i],q.objectives[i]) return -1;
        else if BEATS(q.objectives[i],p.objectives[i]) return  1;

    return 0;
}


int greaterabbrev (const void *v1, const void *v2)
/* this sorts points worsening in the penultimate objective */
{
    int i;
    POINT p = *(POINT*)v1;
    POINT q = *(POINT*)v2;
    int n = p.n; /* assume that p and q have the same size */

    for (i = n - 2; i >= 0; i--)
        if BEATS(p.objectives[i],q.objectives[i]) return -1;
        else if BEATS(q.objectives[i],p.objectives[i]) return  1;

    return 0;
}


int dominates2way(POINT p, POINT q, int k)
/* returns -1 if p dominates q, 1 if q dominates p, 2 if p == q, 0 otherwise
   k is the highest index inspected */
{
    int i, j;

    for (i = k; i >= 0; i--)
        if BEATS(p.objectives[i],q.objectives[i])
        {   for (j = i - 1; j >= 0; j--)
                if BEATS(q.objectives[j],p.objectives[j]) return 0;
            return -1;
        }
        else if BEATS(q.objectives[i],p.objectives[i])
        {   for (j = i - 1; j >= 0; j--)
                if BEATS(p.objectives[j],q.objectives[j]) return 0;
            return  1;
        }
    return 2;
}


int dominates1way(POINT p, POINT q, int k)
/* returns true if p dominates q or p == q, false otherwise
   the assumption is that q doesn't dominate p
   k is the highest index inspected */
{
    int i;

    for (i = k; i >= 0; i--)
        if BEATS(q.objectives[i],p.objectives[i])
            return 0;

    return 1;
}


void makeDominatedBit (FRONT* ps, int p)
/* creates the front ps[0 .. p-1] in fs[fr], with each point bounded by ps[p] and dominated points removed */
{
    int i, j, k;
    int l = 0;
    int u = p - 1;
    int n = ps->n;
    POINT t;

    for (i = p - 1; i >= 0; i--)
        if (BEATS(ps->points[p].objectives[n - 1],ps->points[i].objectives[n - 1]))
        {   fs[fr].points[u].objectives[n - 1] = ps->points[i].objectives[n - 1];
            for (j = 0; j < n - 1; j++)
                fs[fr].points[u].objectives[j] = WORSE(ps->points[p].objectives[j],ps->points[i].objectives[j]);
            u--;
        }
        else
        {   fs[fr].points[l].objectives[n - 1] = ps->points[p].objectives[n - 1];
            for (j = 0; j < n - 1; j++)
                fs[fr].points[l].objectives[j] = WORSE(ps->points[p].objectives[j],ps->points[i].objectives[j]);
            l++;
        }

    /* points below l are all equal in the last objective; points above l are all worse
       points below l can dominate each other, and we don't need to compare the last objective
       points above l cannot dominate points that start below l, and we don't need to compare the last objective */
    fs[fr].nPoints = 1;
    for (i = 1; i < l; i++)
    {
        j = 0;
        while (j < fs[fr].nPoints)
            switch (dominates2way(fs[fr].points[i], fs[fr].points[j], n-2))
            {
            case  0:
                j++;
                break;
            case -1: /* AT THIS POINT WE KNOW THAT i CANNOT BE DOMINATED BY ANY OTHER PROMOTED POINT j
                        SWAP i INTO j, AND 1-WAY DOM FOR THE REST OF THE js */
                t = fs[fr].points[j];
                fs[fr].points[j] = fs[fr].points[i];
                fs[fr].points[i] = t;
                while(j < fs[fr].nPoints - 1 && dominates1way(fs[fr].points[j], fs[fr].points[fs[fr].nPoints - 1], n-1))
                    fs[fr].nPoints--;
                k = j+1;
                while (k < fs[fr].nPoints)
                    if(dominates1way(fs[fr].points[j], fs[fr].points[k], n-2))
                    {   t = fs[fr].points[k];
                        fs[fr].nPoints--;
                        fs[fr].points[k] = fs[fr].points[fs[fr].nPoints];
                        fs[fr].points[fs[fr].nPoints] = t;
                    }
                    else
                        k++;
            default:
                j = fs[fr].nPoints + 1;
            }
        if (j == fs[fr].nPoints)
        {   t = fs[fr].points[fs[fr].nPoints];
            fs[fr].points[fs[fr].nPoints] = fs[fr].points[i];
            fs[fr].points[i] = t;
            fs[fr].nPoints++;
        }
    }
    safe = WORSE(l,fs[fr].nPoints);
    for (i = l; i < p; i++)
    {
        j = 0;
        while (j < safe)
            if(dominates1way(fs[fr].points[j], fs[fr].points[i], n-2))
                j = fs[fr].nPoints + 1;
            else
                j++;
        while (j < fs[fr].nPoints)
            switch (dominates2way(fs[fr].points[i], fs[fr].points[j], n-1))
            {
            case  0:
                j++;
                break;
            case -1: /* AT THIS POINT WE KNOW THAT i CANNOT BE DOMINATED BY ANY OTHER PROMOTED POINT j
		        SWAP i INTO j, AND 1-WAY DOM FOR THE REST OF THE js */
                t = fs[fr].points[j];
                fs[fr].points[j] = fs[fr].points[i];
                fs[fr].points[i] = t;
                while(j < fs[fr].nPoints - 1 && dominates1way(fs[fr].points[j], fs[fr].points[fs[fr].nPoints - 1], n-1))
                    fs[fr].nPoints--;
                k = j+1;
                while (k < fs[fr].nPoints)
                    if(dominates1way(fs[fr].points[j], fs[fr].points[k], n-1))
                    {   t = fs[fr].points[k];
                        fs[fr].nPoints--;
                        fs[fr].points[k] = fs[fr].points[fs[fr].nPoints];
                        fs[fr].points[fs[fr].nPoints] = t;
                    }
                    else
                        k++;
            default:
                j = fs[fr].nPoints + 1;
            }
        if (j == fs[fr].nPoints)
        {   t = fs[fr].points[fs[fr].nPoints];
            fs[fr].points[fs[fr].nPoints] = fs[fr].points[i];
            fs[fr].points[i] = t;
            fs[fr].nPoints++;
        }
    }

    /* Set the number of objectives for all points */
    wfg_front_resize (&fs[fr], fs[fr].nPoints, n);

    fr++;
}


double hv_2dim (FRONT* ps, int k)
/* returns the hypervolume of ps[0 .. k-1] in 2D
   assumes that ps is sorted improving */
{
    int i;

    double volume = ps->points[0].objectives[0] * ps->points[0].objectives[1];
    for (i = 1; i < k; i++)
        volume += ps->points[i].objectives[1] *
                  (ps->points[i].objectives[0] - ps->points[i - 1].objectives[0]);

    return volume;
}

/* RLIST-variant of hv_2dim */
void Rlist_hv_2dim (FRONT* ps, int k, RLIST* Rlist, int sign)
{
    int i, Ridx;
    double xmax0 = 0;

    Rlist_extend (Rlist, k, &Ridx);

    for (i = 0; i < k; i++, Ridx++)
      {
        Rlist->xmin[Ridx][0] = xmax0;
        xmax0 = ps->points[i].objectives[0];
        Rlist->xmax[Ridx][0] = xmax0;
        Rlist->xmax[Ridx][1] = ps->points[i].objectives[1];
        Rlist->sign[Ridx] = sign;
      }
}


double inclhv (POINT p)
/* returns the inclusive hypervolume of p */
{
    int i;

    double volume = 1;
    for (i = 0; i < p.n; i++)
        volume *= p.objectives[i];

    return volume;
}

/* RLIST-variant of inclhv */
void Rlist_inclhv (POINT p, RLIST* Rlist, int sign)
{
    int Ridx;

    Rlist_extend (Rlist, 1, &Ridx);

    memcpy (Rlist->xmax[Ridx], p.objectives, p.n * sizeof (double));
    Rlist->sign[Ridx] = sign;
}


double inclhv2 (POINT p, POINT q)
/* returns the hypervolume of {p, q} */
{
    int i;
    int n = p.n; /* assume that p and q have the same size */
    double vp  = 1;
    double vq  = 1;
    double vpq = 1;

    for (i = 0; i < n; i++)
    {
        vp  *= p.objectives[i];
        vq  *= q.objectives[i];
        vpq *= WORSE(p.objectives[i],q.objectives[i]);
    }

    return vp + vq - vpq;
}

/* RLIST-variant of inclhv2 */
void Rlist_inclhv2 (POINT p, POINT q, RLIST* Rlist, int sign)
{
    int i, Ridx;
    int n = p.n; /* assume that p and q have the same size */

    Rlist_extend (Rlist, 3, &Ridx);

    memcpy (Rlist->xmax[Ridx], p.objectives, n * sizeof (double));  Rlist->sign[Ridx++] = sign;
    memcpy (Rlist->xmax[Ridx], q.objectives, n * sizeof (double));  Rlist->sign[Ridx++] = sign;

    for (i = 0; i < n; i++)
        Rlist->xmax[Ridx][i] = WORSE(p.objectives[i], q.objectives[i]);
    Rlist->sign[Ridx] = -sign;
}


double inclhv3 (POINT p, POINT q, POINT r)
/* returns the hypervolume of {p, q, r} */
{
    int i;
    int n = p.n; /* assume that p, q and r have the same size */
    double vp   = 1;
    double vq   = 1;
    double vr   = 1;
    double vpq  = 1;
    double vpr  = 1;
    double vqr  = 1;
    double vpqr = 1;

    for (i = 0; i < n; i++)
    {
        vp *= p.objectives[i];
        vq *= q.objectives[i];
        vr *= r.objectives[i];
        if (BEATS(p.objectives[i],q.objectives[i]))
            if (BEATS(q.objectives[i],r.objectives[i]))
            {
                vpq  *= q.objectives[i];
                vpr  *= r.objectives[i];
                vqr  *= r.objectives[i];
                vpqr *= r.objectives[i];
            }
            else
            {
                vpq  *= q.objectives[i];
                vpr  *= WORSE(p.objectives[i],r.objectives[i]);
                vqr  *= q.objectives[i];
                vpqr *= q.objectives[i];
            }
        else if (BEATS(p.objectives[i],r.objectives[i]))
        {
            vpq  *= p.objectives[i];
            vpr  *= r.objectives[i];
            vqr  *= r.objectives[i];
            vpqr *= r.objectives[i];
        }
        else
        {
            vpq  *= p.objectives[i];
            vpr  *= p.objectives[i];
            vqr  *= WORSE(q.objectives[i],r.objectives[i]);
            vpqr *= p.objectives[i];
        }
    }
    return vp + vq + vr - vpq - vpr - vqr + vpqr;
}

/* RLIST-variant of inclhv3 */
void Rlist_inclhv3 (POINT p, POINT q, POINT r, RLIST* Rlist, int sign)
{
    int i, Ridx, Ridx_pq, Ridx_pr, Ridx_qr, Ridx_pqr;
    int n = p.n; /* assume that p, q and r have the same size */

    Rlist_extend (Rlist, 7, &Ridx);

    memcpy (Rlist->xmax[Ridx], p.objectives, n * sizeof (double));  Rlist->sign[Ridx ++] = sign;
    memcpy (Rlist->xmax[Ridx], q.objectives, n * sizeof (double));  Rlist->sign[Ridx ++] = sign;
    memcpy (Rlist->xmax[Ridx], r.objectives, n * sizeof (double));  Rlist->sign[Ridx ++] = sign;

    Ridx_pq  = Ridx ++;  Rlist->sign[Ridx_pq]  = -sign;
    Ridx_pr  = Ridx ++;  Rlist->sign[Ridx_pr]  = -sign;
    Ridx_qr  = Ridx ++;  Rlist->sign[Ridx_qr]  = -sign;
    Ridx_pqr = Ridx;     Rlist->sign[Ridx_pqr] =  sign;

    for (i = 0; i < n; i++)
    {
        if (BEATS(p.objectives[i], q.objectives[i]))
            if (BEATS(q.objectives[i], r.objectives[i]))
            {
                Rlist->xmax[Ridx_pq][i]  = q.objectives[i];
                Rlist->xmax[Ridx_pr][i]  = r.objectives[i];
                Rlist->xmax[Ridx_qr][i]  = r.objectives[i];
                Rlist->xmax[Ridx_pqr][i] = r.objectives[i];
            }
            else
            {
                Rlist->xmax[Ridx_pq][i]  = q.objectives[i];
                Rlist->xmax[Ridx_pr][i]  = WORSE(p.objectives[i], r.objectives[i]);
                Rlist->xmax[Ridx_qr][i]  = q.objectives[i];
                Rlist->xmax[Ridx_pqr][i] = q.objectives[i];
            }
        else if (BEATS(p.objectives[i],r.objectives[i]))
        {
            Rlist->xmax[Ridx_pq][i]  = p.objectives[i];
            Rlist->xmax[Ridx_pr][i]  = r.objectives[i];
            Rlist->xmax[Ridx_qr][i]  = r.objectives[i];
            Rlist->xmax[Ridx_pqr][i] = r.objectives[i];
        }
        else
        {
            Rlist->xmax[Ridx_pq][i]  = p.objectives[i];
            Rlist->xmax[Ridx_pr][i]  = p.objectives[i];
            Rlist->xmax[Ridx_qr][i]  = WORSE(q.objectives[i], r.objectives[i]);
            Rlist->xmax[Ridx_pqr][i] = p.objectives[i];
        }
    }
}


double inclhv4 (POINT p, POINT q, POINT r, POINT s)
/* returns the hypervolume of {p, q, r, s} */
{
    int i;
    int n = p.n; /* assume that p, q, r and s have the same size */
    double vp    = 1;
    double vq   = 1;
    double vr   = 1;
    double vs   = 1;
    double vpq   = 1;
    double vpr  = 1;
    double vps  = 1;
    double vqr  = 1;
    double vqs = 1;
    double vrs = 1;
    double vpqr  = 1;
    double vpqs = 1;
    double vprs = 1;
    double vqrs = 1;
    double vpqrs = 1;
    OBJECTIVE z1, z2;

    for (i = 0; i < n; i++)
    {
        vp *= p.objectives[i];
        vq *= q.objectives[i];
        vr *= r.objectives[i];
        vs *= s.objectives[i];
        if (BEATS(p.objectives[i],q.objectives[i]))
            if (BEATS(q.objectives[i],r.objectives[i]))
                if (BEATS(r.objectives[i],s.objectives[i]))
                {
                    vpq *= q.objectives[i];
                    vpr *= r.objectives[i];
                    vps *= s.objectives[i];
                    vqr *= r.objectives[i];
                    vqs *= s.objectives[i];
                    vrs *= s.objectives[i];
                    vpqr *= r.objectives[i];
                    vpqs *= s.objectives[i];
                    vprs *= s.objectives[i];
                    vqrs *= s.objectives[i];
                    vpqrs *= s.objectives[i];
                }
                else
                {
                    z1 = WORSE(q.objectives[i],s.objectives[i]);
                    vpq *= q.objectives[i];
                    vpr *= r.objectives[i];
                    vps *= WORSE(p.objectives[i],s.objectives[i]);
                    vqr *= r.objectives[i];
                    vqs *= z1;
                    vrs *= r.objectives[i];
                    vpqr *= r.objectives[i];
                    vpqs *= z1;
                    vprs *= r.objectives[i];
                    vqrs *= r.objectives[i];
                    vpqrs *= r.objectives[i];
                }
            else if (BEATS(q.objectives[i],s.objectives[i]))
            {
                vpq *= q.objectives[i];
                vpr *= WORSE(p.objectives[i],r.objectives[i]);
                vps *= s.objectives[i];
                vqr *= q.objectives[i];
                vqs *= s.objectives[i];
                vrs *= s.objectives[i];
                vpqr *= q.objectives[i];
                vpqs *= s.objectives[i];
                vprs *= s.objectives[i];
                vqrs *= s.objectives[i];
                vpqrs *= s.objectives[i];
            }
            else
            {
                z1 = WORSE(p.objectives[i],r.objectives[i]);
                vpq *= q.objectives[i];
                vpr *= z1;
                vps *= WORSE(p.objectives[i],s.objectives[i]);
                vqr *= q.objectives[i];
                vqs *= q.objectives[i];
                vrs *= WORSE(r.objectives[i],s.objectives[i]);
                vpqr *= q.objectives[i];
                vpqs *= q.objectives[i];
                vprs *= WORSE(z1,s.objectives[i]);
                vqrs *= q.objectives[i];
                vpqrs *= q.objectives[i];
            }
        else if (BEATS(q.objectives[i],r.objectives[i]))
            if (BEATS(p.objectives[i],s.objectives[i]))
            {
                z1 = WORSE(p.objectives[i],r.objectives[i]);
                z2 = WORSE(r.objectives[i],s.objectives[i]);
                vpq *= p.objectives[i];
                vpr *= z1;
                vps *= s.objectives[i];
                vqr *= r.objectives[i];
                vqs *= s.objectives[i];
                vrs *= z2;
                vpqr *= z1;
                vpqs *= s.objectives[i];
                vprs *= z2;
                vqrs *= z2;
                vpqrs *= z2;
            }
            else
            {
                z1 = WORSE(p.objectives[i],r.objectives[i]);
                z2 = WORSE(r.objectives[i],s.objectives[i]);
                vpq *= p.objectives[i];
                vpr *= z1;
                vps *= p.objectives[i];
                vqr *= r.objectives[i];
                vqs *= WORSE(q.objectives[i],s.objectives[i]);
                vrs *= z2;
                vpqr *= z1;
                vpqs *= p.objectives[i];
                vprs *= z1;
                vqrs *= z2;
                vpqrs *= z1;
            }
        else if (BEATS(p.objectives[i],s.objectives[i]))
        {
            vpq *= p.objectives[i];
            vpr *= p.objectives[i];
            vps *= s.objectives[i];
            vqr *= q.objectives[i];
            vqs *= s.objectives[i];
            vrs *= s.objectives[i];
            vpqr *= p.objectives[i];
            vpqs *= s.objectives[i];
            vprs *= s.objectives[i];
            vqrs *= s.objectives[i];
            vpqrs *= s.objectives[i];
        }
        else
        {
            z1 = WORSE(q.objectives[i],s.objectives[i]);
            vpq *= p.objectives[i];
            vpr *= p.objectives[i];
            vps *= p.objectives[i];
            vqr *= q.objectives[i];
            vqs *= z1;
            vrs *= WORSE(r.objectives[i],s.objectives[i]);
            vpqr *= p.objectives[i];
            vpqs *= p.objectives[i];
            vprs *= p.objectives[i];
            vqrs *= z1;
            vpqrs *= p.objectives[i];
        }
    }
    return vp + vq + vr + vs - vpq - vpr - vps - vqr - vqs - vrs + vpqr + vpqs + vprs + vqrs - vpqrs;
}

void Rlist_inclhv4 (POINT p, POINT q, POINT r, POINT s, RLIST* Rlist, int sign)
/* returns the hypervolume of {p, q, r, s} */
{
    int i, Ridx;
    int Ridx_pq, Ridx_pr, Ridx_ps, Ridx_qr, Ridx_qs, Ridx_rs;
    int Ridx_pqr, Ridx_pqs, Ridx_prs, Ridx_qrs, Ridx_pqrs;

    int n = p.n; /* assume that p, q, r and s have the same size */
    OBJECTIVE z1, z2;

    Rlist_extend (Rlist, 15, &Ridx); /* 15 = 2^4 - 1 */

    memcpy (Rlist->xmax[Ridx], p.objectives, n * sizeof (double));  Rlist->sign[Ridx ++] = sign;
    memcpy (Rlist->xmax[Ridx], q.objectives, n * sizeof (double));  Rlist->sign[Ridx ++] = sign;
    memcpy (Rlist->xmax[Ridx], r.objectives, n * sizeof (double));  Rlist->sign[Ridx ++] = sign;
    memcpy (Rlist->xmax[Ridx], s.objectives, n * sizeof (double));  Rlist->sign[Ridx ++] = sign;

    Ridx_pq   = Ridx ++;  Rlist->sign[Ridx_pq]   = -sign;
    Ridx_pr   = Ridx ++;  Rlist->sign[Ridx_pr]   = -sign;
    Ridx_ps   = Ridx ++;  Rlist->sign[Ridx_ps]   = -sign;
    Ridx_qr   = Ridx ++;  Rlist->sign[Ridx_qr]   = -sign;
    Ridx_qs   = Ridx ++;  Rlist->sign[Ridx_qs]   = -sign;
    Ridx_rs   = Ridx ++;  Rlist->sign[Ridx_rs]   = -sign;
    Ridx_pqr  = Ridx ++;  Rlist->sign[Ridx_pqr]  =  sign;
    Ridx_pqs  = Ridx ++;  Rlist->sign[Ridx_pqs]  =  sign;
    Ridx_prs  = Ridx ++;  Rlist->sign[Ridx_prs]  =  sign;
    Ridx_qrs  = Ridx ++;  Rlist->sign[Ridx_qrs]  =  sign;
    Ridx_pqrs = Ridx;     Rlist->sign[Ridx_pqrs] = -sign;

    for (i = 0; i < n; i++)
    {
        if (BEATS(p.objectives[i], q.objectives[i]))
            if (BEATS(q.objectives[i], r.objectives[i]))
                if (BEATS(r.objectives[i], s.objectives[i]))
                {
                    Rlist->xmax[Ridx_pq][i]   = q.objectives[i];
                    Rlist->xmax[Ridx_pr][i]   = r.objectives[i];
                    Rlist->xmax[Ridx_ps][i]   = s.objectives[i];
                    Rlist->xmax[Ridx_qr][i]   = r.objectives[i];
                    Rlist->xmax[Ridx_qs][i]   = s.objectives[i];
                    Rlist->xmax[Ridx_rs][i]   = s.objectives[i];
                    Rlist->xmax[Ridx_pqr][i]  = r.objectives[i];
                    Rlist->xmax[Ridx_pqs][i]  = s.objectives[i];
                    Rlist->xmax[Ridx_prs][i]  = s.objectives[i];
                    Rlist->xmax[Ridx_qrs][i]  = s.objectives[i];
                    Rlist->xmax[Ridx_pqrs][i] = s.objectives[i];
                }
                else
                {
                    z1 = WORSE(q.objectives[i], s.objectives[i]);
                    Rlist->xmax[Ridx_pq][i]   = q.objectives[i];
                    Rlist->xmax[Ridx_pr][i]   = r.objectives[i];
                    Rlist->xmax[Ridx_ps][i]   = WORSE(p.objectives[i], s.objectives[i]);
                    Rlist->xmax[Ridx_qr][i]   = r.objectives[i];
                    Rlist->xmax[Ridx_qs][i]   = z1;
                    Rlist->xmax[Ridx_rs][i]   = r.objectives[i];
                    Rlist->xmax[Ridx_pqr][i]  = r.objectives[i];
                    Rlist->xmax[Ridx_pqs][i]  = z1;
                    Rlist->xmax[Ridx_prs][i]  = r.objectives[i];
                    Rlist->xmax[Ridx_qrs][i]  = r.objectives[i];
                    Rlist->xmax[Ridx_pqrs][i] = r.objectives[i];
                }
            else if (BEATS(q.objectives[i], s.objectives[i]))
            {
                Rlist->xmax[Ridx_pq][i]   = q.objectives[i];
                Rlist->xmax[Ridx_pr][i]   = WORSE(p.objectives[i], r.objectives[i]);
                Rlist->xmax[Ridx_ps][i]   = s.objectives[i];
                Rlist->xmax[Ridx_qr][i]   = q.objectives[i];
                Rlist->xmax[Ridx_qs][i]   = s.objectives[i];
                Rlist->xmax[Ridx_rs][i]   = s.objectives[i];
                Rlist->xmax[Ridx_pqr][i]  = q.objectives[i];
                Rlist->xmax[Ridx_pqs][i]  = s.objectives[i];
                Rlist->xmax[Ridx_prs][i]  = s.objectives[i];
                Rlist->xmax[Ridx_qrs][i]  = s.objectives[i];
                Rlist->xmax[Ridx_pqrs][i] = s.objectives[i];
            }
            else
            {
                z1 = WORSE(p.objectives[i], r.objectives[i]);
                Rlist->xmax[Ridx_pq][i]   = q.objectives[i];
                Rlist->xmax[Ridx_pr][i]   = z1;
                Rlist->xmax[Ridx_ps][i]   = WORSE(p.objectives[i], s.objectives[i]);
                Rlist->xmax[Ridx_qr][i]   = q.objectives[i];
                Rlist->xmax[Ridx_qs][i]   = q.objectives[i];
                Rlist->xmax[Ridx_rs][i]   = WORSE(r.objectives[i], s.objectives[i]);
                Rlist->xmax[Ridx_pqr][i]  = q.objectives[i];
                Rlist->xmax[Ridx_pqs][i]  = q.objectives[i];
                Rlist->xmax[Ridx_prs][i]  = WORSE(z1, s.objectives[i]);
                Rlist->xmax[Ridx_qrs][i]  = q.objectives[i];
                Rlist->xmax[Ridx_pqrs][i] = q.objectives[i];
            }
        else if (BEATS(q.objectives[i], r.objectives[i]))
            if (BEATS(p.objectives[i], s.objectives[i]))
            {
                z1 = WORSE(p.objectives[i], r.objectives[i]);
                z2 = WORSE(r.objectives[i], s.objectives[i]);
                Rlist->xmax[Ridx_pq][i]   = p.objectives[i];
                Rlist->xmax[Ridx_pr][i]   = z1;
                Rlist->xmax[Ridx_ps][i]   = s.objectives[i];
                Rlist->xmax[Ridx_qr][i]   = r.objectives[i];
                Rlist->xmax[Ridx_qs][i]   = s.objectives[i];
                Rlist->xmax[Ridx_rs][i]   = z2;
                Rlist->xmax[Ridx_pqr][i]  = z1;
                Rlist->xmax[Ridx_pqs][i]  = s.objectives[i];
                Rlist->xmax[Ridx_prs][i]  = z2;
                Rlist->xmax[Ridx_qrs][i]  = z2;
                Rlist->xmax[Ridx_pqrs][i] = z2;
            }
            else
            {
                z1 = WORSE(p.objectives[i], r.objectives[i]);
                z2 = WORSE(r.objectives[i], s.objectives[i]);
                Rlist->xmax[Ridx_pq][i]   = p.objectives[i];
                Rlist->xmax[Ridx_pr][i]   = z1;
                Rlist->xmax[Ridx_ps][i]   = p.objectives[i];
                Rlist->xmax[Ridx_qr][i]   = r.objectives[i];
                Rlist->xmax[Ridx_qs][i]   = WORSE(q.objectives[i], s.objectives[i]);
                Rlist->xmax[Ridx_rs][i]   = z2;
                Rlist->xmax[Ridx_pqr][i]  = z1;
                Rlist->xmax[Ridx_pqs][i]  = p.objectives[i];
                Rlist->xmax[Ridx_prs][i]  = z1;
                Rlist->xmax[Ridx_qrs][i]  = z2;
                Rlist->xmax[Ridx_pqrs][i] = z1;
            }
        else if (BEATS(p.objectives[i], s.objectives[i]))
        {
            Rlist->xmax[Ridx_pq][i]   = p.objectives[i];
            Rlist->xmax[Ridx_pr][i]   = p.objectives[i];
            Rlist->xmax[Ridx_ps][i]   = s.objectives[i];
            Rlist->xmax[Ridx_qr][i]   = q.objectives[i];
            Rlist->xmax[Ridx_qs][i]   = s.objectives[i];
            Rlist->xmax[Ridx_rs][i]   = s.objectives[i];
            Rlist->xmax[Ridx_pqr][i]  = p.objectives[i];
            Rlist->xmax[Ridx_pqs][i]  = s.objectives[i];
            Rlist->xmax[Ridx_prs][i]  = s.objectives[i];
            Rlist->xmax[Ridx_qrs][i]  = s.objectives[i];
            Rlist->xmax[Ridx_pqrs][i] = s.objectives[i];
        }
        else
        {
            z1 = WORSE(q.objectives[i], s.objectives[i]);
            Rlist->xmax[Ridx_pq][i]   = p.objectives[i];
            Rlist->xmax[Ridx_pr][i]   = p.objectives[i];
            Rlist->xmax[Ridx_ps][i]   = p.objectives[i];
            Rlist->xmax[Ridx_qr][i]   = q.objectives[i];
            Rlist->xmax[Ridx_qs][i]   = z1;
            Rlist->xmax[Ridx_rs][i]   = WORSE(r.objectives[i], s.objectives[i]);
            Rlist->xmax[Ridx_pqr][i]  = p.objectives[i];
            Rlist->xmax[Ridx_pqs][i]  = p.objectives[i];
            Rlist->xmax[Ridx_prs][i]  = p.objectives[i];
            Rlist->xmax[Ridx_qrs][i]  = z1;
            Rlist->xmax[Ridx_pqrs][i] = p.objectives[i];
        }
    }
}


double exclhv (FRONT* ps, int p)
/* returns the exclusive hypervolume of ps[p] relative to ps[0 .. p-1] */
{
    double volume;

    makeDominatedBit (ps, p);
    volume = inclhv (ps->points[p]) - hv (&fs[fr - 1]);
    fr--;

    return volume;
}

/* RLIST-variant of exclhv */
void Rlist_exclhv (FRONT* ps, int p, RLIST* Rlist, int sign)
{
    makeDominatedBit (ps, p);
    Rlist_inclhv (ps->points[p], Rlist, sign);
    Rlist_hv (&fs[fr - 1], Rlist, -sign);

    fr --;
}


double hv (FRONT* ps)
/* returns the hypervolume of ps[0 ..] */
{
    int i;
    int n = ps->n;
    double volume;

    /* process small fronts with the IEA */
    switch (ps->nPoints)
    {
    case 1:
        return inclhv (ps->points[0]);
    case 2:
        return inclhv2 (ps->points[0], ps->points[1]);
    case 3:
        return inclhv3 (ps->points[0], ps->points[1], ps->points[2]);
    case 4:
        return inclhv4 (ps->points[0], ps->points[1], ps->points[2], ps->points[3]);
    }

    /* these points need sorting */
    qsort(&ps->points[safe], ps->nPoints - safe, sizeof(POINT), greater);

    /* n = 2 implies that safe = 0 */
    if (n == 2) return hv_2dim (ps, ps->nPoints);

    /* these points don't NEED sorting, but it helps */
    qsort(ps->points, safe, sizeof(POINT), greaterabbrev);

    if (n == 3 && safe > 0)
    {
        volume = ps->points[0].objectives[2] * (hv_2dim (ps, safe));
        i = safe;
    }
    else
    {
        volume = inclhv4 (ps->points[0], ps->points[1],
                          ps->points[2], ps->points[3]);
        i = 4;
    }

    wfg_front_resize (ps, ps->nPoints, n - 1);

    for (; i < ps->nPoints; i++)
        /* we can ditch dominated points here,
           but they will be ditched anyway in makeDominatedBit */
        volume += ps->points[i].objectives[n - 1] * (exclhv (ps, i));

    wfg_front_resize (ps, ps->nPoints, n);

    return volume;
}

/* RLIST-variant of hv */
void Rlist_hv (FRONT* ps, RLIST* Rlist, int sign)
{
    int i, j, Ridx;
    int n = ps->n;

    /* process small fronts with the IEA */
    switch (ps->nPoints)
      {
      case 1:
        Rlist_inclhv  (ps->points[0], Rlist, sign);
        return;
      case 2:
        Rlist_inclhv2 (ps->points[0], ps->points[1], Rlist, sign);
        return;
      case 3:
        Rlist_inclhv3 (ps->points[0], ps->points[1], ps->points[2],
                       Rlist, sign);
        return;
      case 4:
        Rlist_inclhv4 (ps->points[0], ps->points[1], ps->points[2],
                       ps->points[3], Rlist, sign);
        return;
      }

    /* these points need sorting */
    qsort (&ps->points[safe], ps->nPoints - safe, sizeof(POINT), greater);

    /* n = 2 implies that safe = 0 */
    if (n == 2)
      {
        Rlist_hv_2dim (ps, ps->nPoints, Rlist, sign);
        return;
      }

    /* these points don't NEED sorting, but it helps */
    qsort (ps->points, safe, sizeof(POINT), greaterabbrev);

    if ((n == 3) && (safe > 0))
      {
        /* Take note of the number of rectangles before calling Rlist_hv_2dim */
        Ridx = Rlist->size;

        Rlist_hv_2dim (ps, safe, Rlist, sign);

        /* Add last coordinate to all new rectangles */
        for (j = Ridx; j < Rlist->size; j++)
          Rlist->xmax[j][2] = ps->points[0].objectives[2];

        i = safe;
      }
    else
      {
        Rlist_inclhv4 (ps->points[0], ps->points[1], ps->points[2],
                       ps->points[3], Rlist, sign);
        i = 4;
      }

    wfg_front_resize (ps, ps->nPoints, n - 1);

    for (; i < ps->nPoints; i++)
    {
      /* Take note of the number of rectangles before calling Rlist_exclhv */
      Ridx = Rlist->size;

      Rlist_exclhv (ps, i, Rlist, sign);

      /* Add last coordinate to all new rectangles */
      for (j = Ridx; j < Rlist->size; j++)
        Rlist->xmax[j][n - 1] = ps->points[i].objectives[n - 1];
    }

    wfg_front_resize (ps, ps->nPoints, n);
}


/**************************/
/***** MAIN FUNCTIONS *****/
/**************************/

double wfg_compute_hv (FRONT* ps)
{
  /* Set global variables */
  safe = 0;
  fr = 0;

  return hv (ps);
}

void wfg_compute_decomposition (FRONT* ps, RLIST* Rlist)
{
  /* Set global variables */
  safe = 0;
  fr = 0;

  Rlist_hv (ps, Rlist, 1);
}


/********************************************/
/***** ALLOC/FREE GLOBAL LIST OF FRONTS *****/
/********************************************/

void wfg_alloc (int maxm, int maxn)
/* Allocate memory for several auxiliary fronts */
{
  int i, max_depth;

  if (maxn > 2)
    {
      max_depth = maxn - 2;
      fs = (FRONT*) mxMalloc (sizeof (FRONT) * max_depth);
      for (i = 0; i < max_depth; i++)
        wfg_front_init (&fs[i], maxm, maxn - i - 1);
    }
}


void wfg_free (int maxm, int maxn)
{
  int i, max_depth;

  if (maxn > 2)
    {
      max_depth = maxn - 2;
      for (i = 0; i < max_depth; i++)
        wfg_front_destroy (&fs[i]);
      mxFree (fs);
    }
}


/**************************************/
/***** BASIC OPERATIONS ON FRONTS *****/
/**************************************/

void wfg_front_init (FRONT* front, int nb_points, int nb_objectives)
{
  int j;

  front->nPoints_alloc = nb_points;  /* must *not* be changed */
  front->n_alloc = nb_objectives;  /* must *not* be changed */

  front->nPoints = nb_points;
  front->n = nb_objectives;

  front->points = (POINT*) mxMalloc (sizeof (POINT) * nb_points);

  for (j = 0; j < nb_points; j++)
    {
      front->points[j].n = nb_objectives;
      front->points[j].objectives = (OBJECTIVE*)
        mxMalloc (sizeof (OBJECTIVE) * nb_objectives);
    }
}


void wfg_front_destroy (FRONT* front)
{
  int j;

  for (j = 0; j < front->nPoints_alloc; j++)
    mxFree (front->points[j].objectives);

  mxFree (front->points);
}


void wfg_front_resize (FRONT* f, int nb_points, int nb_objectives)
{
  int j;

  if (nb_points > f->nPoints_alloc)
    mexErrMsgTxt ("Cannot set nPoints > nPoints_alloc.");

  if (nb_objectives > f->n_alloc)
    mexErrMsgTxt ("Cannot set n > n_alloc.");

  f->nPoints = nb_points;
  f->n = nb_objectives;

  for (j = 0; j < nb_points; j++)
    f->points[j].n = nb_objectives;
}


/***************************************/
/***** BASIC OPERATIONS ON RLIST's *****/
/***************************************/

RLIST* Rlist_alloc (int alloc_size, int n)
{
  int block_size = n * alloc_size;

  RLIST* Rlist = (RLIST*) mxMalloc (sizeof (RLIST));

  Rlist->size = 0;
  Rlist->allocated_size = alloc_size;
  Rlist->n = n;

  Rlist->xmin = (double**) mxMalloc (alloc_size * sizeof (double*));
  Rlist->xmax = (double**) mxMalloc (alloc_size * sizeof (double*));
  Rlist->sign = (int*) mxMalloc (alloc_size * sizeof (int));

  Rlist->xmin_data = (double*) mxMalloc (block_size * sizeof (double));
  Rlist->xmax_data = (double*) mxMalloc (block_size * sizeof (double));

  return Rlist;
}

void Rlist_extend (RLIST* Rlist, int k, int* p_Ridx)
{
  int i, j;
  int n = Rlist->n;
  int old_size = Rlist->size;
  int new_size = old_size + k;
  int block_size;

  if (new_size > Rlist->allocated_size)
    {
      while (new_size > Rlist->allocated_size)
        Rlist->allocated_size *= 2;
      block_size = n * Rlist->allocated_size;

      Rlist->xmin = (double**) mxRealloc
        (Rlist->xmin, Rlist->allocated_size * sizeof (double*));
      Rlist->xmax = (double**) mxRealloc
        (Rlist->xmax, Rlist->allocated_size * sizeof (double*));
      Rlist->sign = (int*) mxRealloc
        (Rlist->sign, Rlist->allocated_size * sizeof (int));

      Rlist->xmin_data = (double*) mxRealloc
        (Rlist->xmin_data, block_size * sizeof (double));
      Rlist->xmax_data = (double*) mxRealloc
        (Rlist->xmax_data, block_size * sizeof (double));

      /* We have to fill xmin and xmax entirely again
         (since xmin_data and xmax_data might have been moved during realloc */
      for (i = 0, j = 0; i < new_size; i++, j += n)
        {
          Rlist->xmin[i] = &(Rlist->xmin_data[j]);
          Rlist->xmax[i] = &(Rlist->xmax_data[j]);
        }
    }
  else
    {
      /* No realloc: we just have to fill up from old_size */
      for (i = old_size, j = n * old_size; i < new_size; i++, j += n)
        {
          Rlist->xmin[i] = &(Rlist->xmin_data[j]);
          Rlist->xmax[i] = &(Rlist->xmax_data[j]);
        }
    }

  Rlist->size = new_size;

  /* Set all components of xmin to 0 (the reference) */
  for (j = n * old_size; j < n * new_size; j++)
    Rlist->xmin_data[j] = 0.0;

  *p_Ridx = old_size;
}

void Rlist_free (RLIST* Rlist)
{
  mxFree (Rlist->xmin);
  mxFree (Rlist->xmin_data);
  mxFree (Rlist->xmax);
  mxFree (Rlist->xmax_data);
  mxFree (Rlist->sign);
  mxFree (Rlist);
}
