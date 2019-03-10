#include <stdlib.h>
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "algorithm.h"
typedef CalcPath_session * PathFinding;

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
		SV * avoidWalls
		SV * width
		SV * height
		SV * startx
		SV * starty
		SV * destx
		SV * desty
		SV * time_max
	
	PREINIT:
		char *weight_map_data = NULL;
	
	CODE:
		
		/* If the object was already initiated, clean map memory */
		if (session->initialized) {
			free_currentMap(session);
			session->initialized = 0;
		}
		
		/* If the path has already been calculated on this object, clean openlist memory */
		if (session->run) {
			free_openList(session);
			session->run = 0;
		}
		
		/* Check for any missing arguments */
		if (!session || !weight_map || !avoidWalls || !width || !height || !startx || !starty || !destx || !desty || !time_max) {
			printf("[pathfinding reset error] missing argument\n");
			XSRETURN_NO;
		}
		
		/* Check for any bad arguments */
		if (SvROK(avoidWalls) || SvTYPE(avoidWalls) >= SVt_PVAV || !SvOK(avoidWalls)) {
			printf("[pathfinding reset error] bad avoidWalls argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(width) || SvTYPE(width) >= SVt_PVAV || !SvOK(width)) {
			printf("[pathfinding reset error] bad width argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(height) || SvTYPE(height) >= SVt_PVAV || !SvOK(height)) {
			printf("[pathfinding reset error] bad height argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(startx) || SvTYPE(startx) >= SVt_PVAV || !SvOK(startx)) {
			printf("[pathfinding reset error] bad startx argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(starty) || SvTYPE(starty) >= SVt_PVAV || !SvOK(starty)) {
			printf("[pathfinding reset error] bad starty argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(destx) || SvTYPE(destx) >= SVt_PVAV || !SvOK(destx)) {
			printf("[pathfinding reset error] bad destx argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(desty) || SvTYPE(desty) >= SVt_PVAV || !SvOK(desty)) {
			printf("[pathfinding reset error] bad desty argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(time_max) || SvTYPE(time_max) >= SVt_PVAV || !SvOK(time_max)) {
			printf("[pathfinding reset error] bad time_max argument\n");
			XSRETURN_NO;
		}
		
		if (!SvROK(weight_map) || !SvOK(weight_map)) {
			printf("[pathfinding reset error] bad weight_map argument\n");
			XSRETURN_NO;
		}
		
		/* Get the weight_map data */
		weight_map_data = (char *) SvPV_nolen (SvRV (weight_map));
		session->map_base_weight = weight_map_data;
		
		session->width = (unsigned long) SvUV (width);
		session->height = (unsigned long) SvUV (height);
		
		session->startX = (int) SvUV (startx);
		session->startY = (int) SvUV (starty);
		session->endX = (int) SvUV (destx);
		session->endY = (int) SvUV (desty);
		
		session->avoidWalls = (unsigned short) SvUV (avoidWalls);
		session->time_max = (unsigned int) SvUV (time_max);
		
		/* Initializes all cells in the map */
		CalcPath_init(session);


int
PathFinding_update_solution(session, new_start_x, new_start_y, weight_changes_array)
		PathFinding session
		SV * new_start_x
		SV * new_start_y
		SV *weight_changes_array
		
	CODE:
		if (!session->initialized) {
			printf("[pathfinding update_solution error] cannot call update_solution before calling reset\n");
			XSRETURN_NO;
		}
		
		/* Check for any missing arguments */
		if (!session || !new_start_x || !new_start_y || !weight_changes_array) {
			printf("[pathfinding update_solution error] missing argument\n");
			XSRETURN_NO;
		}
		
		/* Check for any bad arguments */
		if (SvROK(new_start_x) || SvTYPE(new_start_x) >= SVt_PVAV || !SvOK(new_start_x)) {
			printf("[pathfinding update_solution error] bad new_start_x argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(new_start_y) || SvTYPE(new_start_y) >= SVt_PVAV || !SvOK(new_start_y)) {
			printf("[pathfinding update_solution error] bad new_start_y argument\n");
			XSRETURN_NO;
		}
		
		/* weight_changes_array should be a reference to an array */
		if (!SvROK(weight_changes_array)) {
			printf("[pathfinding update_solution error] weight_changes_array is not a reference\n");
			XSRETURN_NO;
		}
		
		if (SvTYPE(SvRV(weight_changes_array)) != SVt_PVAV) {
			printf("[pathfinding update_solution error] weight_changes_array is not an array reference\n");
			XSRETURN_NO;
		}
		
		if (!SvOK(weight_changes_array)) {
			printf("[pathfinding update_solution error] weight_changes_array is not defined\n");
			XSRETURN_NO;
		}
		
		AV *deref_weight_changes_array;
		I32 array_last_index;
		
		deref_weight_changes_array = (AV *) SvRV (weight_changes_array);
		array_last_index = av_top_index (deref_weight_changes_array);
		
		if (array_last_index == -1) {
			printf("[pathfinding update_solution error] weight_changes_array has no members\n");
			XSRETURN_NO;
		}
		
		int new_x = (int) SvIV (new_start_x);
		int new_y = (int) SvIV (new_start_y);
		
		if (new_x != session->startX || new_y != session->startY) {
			session->k += heuristic_cost_estimate(new_x, new_y, session->startX, session->startY, session->avoidWalls);
			session->startX = new_x;
			session->startY = new_y;
		}
		
		SV **fetched;
		HV *hash;
		
		SV **ref_x;
		SV **ref_y;
		SV **ref_weight;
		
		IV x;
		IV y;
		IV weight;
		
		I32 index;
		
		int result;
		
		for (index = 0; index <= array_last_index; index++) {
			
			fetched = av_fetch (deref_weight_changes_array, index, 0);
			
			if (!SvROK(*fetched)) {
				printf("[pathfinding update_solution error] member of array is not a reference\n");
				XSRETURN_NO;
			}
			
			if (SvTYPE(SvRV(*fetched)) != SVt_PVHV) {
				printf("[pathfinding update_solution error] member of array is not a reference to a hash\n");
				XSRETURN_NO;
			}
			
			if (!SvOK(*fetched)) {
				printf("[pathfinding update_solution error] member of array is not defined\n");
				XSRETURN_NO;
			}
			
			hash = (HV*) SvRV(*fetched);
			
			if (!hv_exists(hash, "x", 1)) {
				printf("[pathfinding update_solution error] member of array does not contain the key 'x'\n");
				XSRETURN_NO;
			}
			
			ref_x = hv_fetch(hash, "x", 1, 0);
			
			if (SvROK(*ref_x)) {
				printf("[pathfinding update_solution error] member of array 'x' key is a reference\n");
				XSRETURN_NO;
			}
			
			if (SvTYPE(*ref_x) >= SVt_PVAV) {
				printf("[pathfinding update_solution error] member of array 'x' key is not a scalar\n");
				XSRETURN_NO;
			}
			
			if (!SvOK(*ref_x)) {
				printf("[pathfinding update_solution error] member of array 'x' key is not defined\n");
				XSRETURN_NO;
			}
			
			x = SvIV(*ref_x);
			
			if (!hv_exists(hash, "y", 1)) {
				printf("[pathfinding update_solution error] member of array does not contain the key 'y'\n");
				XSRETURN_NO;
			}
			
			ref_y = hv_fetch(hash, "y", 1, 0);
			
			if (SvROK(*ref_y)) {
				printf("[pathfinding update_solution error] member of array 'y' key is a reference\n");
				XSRETURN_NO;
			}
			
			if (SvTYPE(*ref_y) >= SVt_PVAV) {
				printf("[pathfinding update_solution error] member of array 'y' key is not a scalar\n");
				XSRETURN_NO;
			}
			
			if (!SvOK(*ref_y)) {
				printf("[pathfinding update_solution error] member of array 'y' key is not defined\n");
				XSRETURN_NO;
			}
			
			y = SvIV(*ref_y);
			
			if (!hv_exists(hash, "weight", 6)) {
				printf("[pathfinding update_solution error] member of array does not contain the key 'weight'\n");
				XSRETURN_NO;
			}
			
			ref_weight = hv_fetch(hash, "weight", 6, 0);
			
			if (SvROK(*ref_weight)) {
				printf("[pathfinding update_solution error] member of array 'weight' key is a reference\n");
				XSRETURN_NO;
			}
			
			if (SvTYPE(*ref_weight) >= SVt_PVAV) {
				printf("[pathfinding update_solution error] member of array 'weight' key is not a scalar\n");
				XSRETURN_NO;
			}
			
			if (!SvOK(*ref_weight)) {
				printf("[pathfinding update_solution error] member of array 'weight' key is not defined\n");
				XSRETURN_NO;
			}
			
			weight = SvIV(*ref_weight);
			
			result = updateChangedMap(session, x, y, weight);
			
			if (!result) {
				printf("[pathfinding update_solution error] updateChangedMap failed\n");
				XSRETURN_NO;
			}
		}
		RETVAL = 1;
	OUTPUT:
		RETVAL


int
PathFinding_run(session, solution_array)
		PathFinding session
		SV *solution_array
	PREINIT:
		int status;
	CODE:
		
		/* Check for any missing arguments */
		if (!session || !solution_array) {
			printf("[pathfinding run error] missing argument\n");
			XSRETURN_NO;
		}
		
		/* solution_array should be a reference to an array */
		if (!SvROK(solution_array)) {
			printf("[pathfinding run error] solution_array is not a reference\n");
			XSRETURN_NO;
		}
		
		if (SvTYPE(SvRV(solution_array)) != SVt_PVAV) {
			printf("[pathfinding run error] solution_array is not an array reference\n");
			XSRETURN_NO;
		}
		
		if (!SvOK(solution_array)) {
			printf("[pathfinding run error] solution_array is not defined\n");
			XSRETURN_NO;
		}
		
		status = CalcPath_pathStep (session);
		
		if (status == -2) {
			printf("[pathfinding run error] You must call 'reset' before 'run'.\n");
			RETVAL = -2;
		
		} else if (status == -1) {
			RETVAL = -1;

		} else if (status > 0) {
			AV *array;
			int size;

			size = session->solution_size;
 			array = (AV *) SvRV (solution_array);
			if (av_len (array) > size)
				av_clear (array);
			
			av_extend (array, session->solution_size);
			
			Node currentNode = session->currentMap[(session->startY * session->width) + session->startX];
			
			Node sucessor;

			while (currentNode.x != session->endX || currentNode.y != session->endY)
			{
				sucessor = session->currentMap[currentNode.sucessor];
				
				HV * rh = (HV *)sv_2mortal((SV *)newHV());

				hv_store(rh, "x", 1, newSViv(sucessor.x), 0);

				hv_store(rh, "y", 1, newSViv(sucessor.y), 0);
				
				av_push(array, newRV((SV *)rh));
				
				currentNode = sucessor;
			}
			
			RETVAL = size;

		} else {
			printf("[pathfinding run error] Pathfinding ended before provided time.\n");
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
			
			Node sucessor;

			while (currentNode.x != session->endX || currentNode.y != session->endY)
			{
				sucessor = session->currentMap[currentNode.sucessor];
				
				HV * rh = (HV *)sv_2mortal((SV *)newHV());

				hv_store(rh, "x", 1, newSViv(sucessor.x), 0);

				hv_store(rh, "y", 1, newSViv(sucessor.y), 0);
				
				av_unshift(results, 1);

				av_store(results, 0, newRV((SV *)rh));
				
				currentNode = sucessor;
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
