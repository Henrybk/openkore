#include <stdlib.h>
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "algorithm.h"
typedef CalcPath_session * PathFinding;


/* Convenience function for checking whether pv is a reference, and dereference it if necessary */
static inline SV *
derefPV (SV *pv)
{
	if (SvTYPE (pv) == SVt_RV) {
		return SvRV (pv);
	} else
		return pv;
}


MODULE = PathFinding		PACKAGE = PathFinding		PREFIX = PathFinding_
PROTOTYPES: ENABLE




PathFinding
PathFinding_create()
	CODE:
		RETVAL = CalcPath_new ();

	OUTPUT:
		RETVAL


void
PathFinding__reset(session, weight_map, avoidWalls, width, height, startx, starty, destx, desty, time_max)
		PathFinding session
		SV *weight_map
		unsigned short avoidWalls
		unsigned long width
		unsigned long height
		unsigned short startx
		unsigned short starty
		unsigned short destx
		unsigned short desty
		unsigned int time_max
	
	PREINIT:
		unsigned char *data = NULL;
	
	CODE:
		
		if (session->initialized) {
			free(session->currentMap);
			session->initialized = 0;
		}
		
		if (session->run) {
			free(session->openList);
			session->run = 0;
		}
		
		/* Sanity check the weight_map parameter and get the weight_map data */
        if (weight_map && SvOK (weight_map))
            data = (unsigned char *) SvPV_nolen (derefPV (weight_map));
        if (!data)
            croak("The 'weight_map' parameter must be a valid scalar.\n");
		
		session->width = width;
		session->height = height;
		session->map = data;
		
		session->currentMap = (Node*) calloc(session->height * session->width, sizeof(Node));
		
		session->startX = startx;
		session->startY = starty;
		session->endX = destx;
		session->endY = desty;
		
		session->avoidWalls = avoidWalls;
		session->time_max = time_max;
		
		CalcPath_init (session);


void
PathFinding_update_cell(session, newstX, newstY, r_array)
		PathFinding session
		unsigned int newstX
		unsigned int newstY
		SV *r_array
		
	INIT:
		int ok;
		SV *ref;
		AV *array;
		I32 len;
		
	CODE:
		/* Sanity check */
		ok = SvOK (r_array);
		if (ok) {
			ref = SvRV (r_array);
			ok = SvTYPE (ref) == SVt_PVAV;
		}
		if (ok) {
			array = (AV *) SvRV (r_array);
			len = av_len (array);
			if (len < 0)
				ok = 0;
		}
		
		if (newstX != session->startX || newstY != session->startY) {
			session->k += heuristic_cost_estimate(newstX, newstY, session->startX, session->startY, session->avoidWalls);
			session->startX = newstX;
			session->startY = newstY;
		}
		
		if (ok) {
			I32 i;
			for (i = 0; i <= len; i++) {
				
				SV **fetched;
				
				HV *hash;
				
				SV **ref_x;
				SV **ref_y;
				SV **ref_weight;
				
				IV x;
				IV y;
				IV weight;
				
				fetched = av_fetch (array, i, 0);
				
				hash = (HV*) SvRV(*fetched);
				
				ref_x = hv_fetch (hash, "x", 1, 0);
				x = SvIV(*ref_x);
				
				ref_y = hv_fetch (hash, "y", 1, 0);
				y = SvIV(*ref_y);
				
				ref_weight = hv_fetch (hash, "weight", 6, 0);
				weight = SvIV(*ref_weight);
				
				updateChangedMap(session, x, y, weight);
			}
		}


int
PathFinding_run(session, r_array)
		PathFinding session
		SV *r_array
	PREINIT:
		int status;
	CODE:
		if (!r_array || !SvOK (r_array) || SvTYPE (r_array) != SVt_RV || SvTYPE (SvRV (r_array)) != SVt_PVAV) {
			croak ("PathFinding::run(session, r_array): r_array must be a reference to an array\n");
			XSRETURN_IV (-1);
		}

		status = CalcPath_pathStep (session);
		if (status < 0) {
			RETVAL = -1;

		} else if (status > 0) {
			AV *array;
			int size;

			size = session->solution_size;
 			array = (AV *) SvRV (r_array);
			if (av_len (array) > size)
				av_clear (array);
			
			av_extend (array, session->solution_size);
			
			Node currentNode = session->currentMap[(session->startY * session->width) + session->startX];

			while (currentNode.x != session->endX || currentNode.y != session->endY)
			{
				HV * rh = (HV *)sv_2mortal((SV *)newHV());

				hv_store(rh, "x", 1, newSViv(currentNode.x), 0);

				hv_store(rh, "y", 1, newSViv(currentNode.y), 0);
				
				av_push(array, newRV((SV *)rh));
				
				currentNode = session->currentMap[currentNode.sucessor];
			}
			RETVAL = size;

		} else {
			RETVAL = 0;
		}
	OUTPUT:
		RETVAL

SV *
PathFinding_runref(session)
		PathFinding session
	PREINIT:
		int status;
	CODE:
		status = CalcPath_pathStep (session);
		if (status < 0) {
			XSRETURN_UNDEF;

		} else if (status > 0) {
			AV * results;

			results = (AV *)sv_2mortal((SV *)newAV());
			av_extend(results, session->solution_size);
			
			Node currentNode = session->currentMap[(session->startY * session->width) + session->startX];

			while (currentNode.x != session->endX || currentNode.y != session->endY)
			{
				HV * rh = (HV *)sv_2mortal((SV *)newHV());

				hv_store(rh, "x", 1, newSViv(currentNode.x), 0);

				hv_store(rh, "y", 1, newSViv(currentNode.y), 0);
				
				av_unshift(results, 1);

				av_store(results, 0, newRV((SV *)rh));
				
				currentNode = session->currentMap[currentNode.sucessor];
			}
			
			RETVAL = newRV((SV *)results);

		} else {
			XSRETURN_NO;
		}
	OUTPUT:
		RETVAL

int
PathFinding_runcount(session)
		PathFinding session
	PREINIT:
		int status;
	CODE:

		status = CalcPath_pathStep (session);
		if (status < 0) {

			RETVAL = -1;
		} else if (status > 0) {
			RETVAL = (int) session->solution_size;

		} else
			RETVAL = 0;
	OUTPUT:
		RETVAL

void
PathFinding_DESTROY(session)
		PathFinding session
	PREINIT:
		session = (PathFinding) 0; /* shut up compiler warning */
	CODE:
		CalcPath_destroy (session);
