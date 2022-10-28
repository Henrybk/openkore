#include <stdlib.h>
#include <time.h>
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
PathFinding_DESTROY(session)
		PathFinding session
	PREINIT:
		session = (PathFinding) 0; /* shut up compiler warning */
	CODE:
		CalcPath_destroy (session);

void
PathFinding__reset(session, weight_map, avoidWalls, customWeights, secondWeightMap, randomFactor, useManhattan, width, height, startx, starty, destx, desty, time_max, min_x, max_x, min_y, max_y, max_steps)
		PathFinding session
		SV * weight_map
		SV * avoidWalls
		SV * customWeights
		SV * secondWeightMap
		SV * randomFactor
		SV * useManhattan
		SV * width
		SV * height
		SV * startx
		SV * starty
		SV * destx
		SV * desty
		SV * time_max
		SV * min_x
		SV * max_x
		SV * min_y
		SV * max_y
		SV * max_steps
	
	PREINIT:
		char *weight_map_data = NULL;
	
	CODE:
		//printf("[PathFinding__reset] start\n");
		
		/* If the object was already initiated, clean map memory */
		if (session->initialized) {
			free_initialized(session);
			session->initialized = 0;
		}
		
		/* Check for any missing arguments */
		if (!session || !weight_map || !avoidWalls  || !customWeights || !secondWeightMap || !randomFactor || !useManhattan || !width || !height || !startx || !starty || !destx || !desty || !time_max || !min_x || !max_x || !min_y || !max_y || !max_steps) {
			printf("[pathfinding reset error] missing argument\n");
			XSRETURN_NO;
		}
		
		/* Check for any bad arguments */
		if (SvROK(avoidWalls) || SvTYPE(avoidWalls) >= SVt_PVAV || !SvOK(avoidWalls)) {
			printf("[pathfinding reset error] bad avoidWalls argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(customWeights) || SvTYPE(customWeights) >= SVt_PVAV || !SvOK(customWeights)) {
			printf("[pathfinding reset error] bad customWeights argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(randomFactor) || SvTYPE(randomFactor) >= SVt_PVAV || !SvOK(randomFactor)) {
			printf("[pathfinding reset error] bad randomFactor argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(useManhattan) || SvTYPE(useManhattan) >= SVt_PVAV || !SvOK(useManhattan)) {
			printf("[pathfinding reset error] bad useManhattan argument\n");
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
		
		if (SvROK(min_x) || SvTYPE(min_x) >= SVt_PVAV || !SvOK(min_x)) {
			printf("[pathfinding reset error] bad min_x argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(max_x) || SvTYPE(max_x) >= SVt_PVAV || !SvOK(max_x)) {
			printf("[pathfinding reset error] bad max_x argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(min_y) || SvTYPE(min_y) >= SVt_PVAV || !SvOK(min_y)) {
			printf("[pathfinding reset error] bad min_y argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(max_y) || SvTYPE(max_y) >= SVt_PVAV || !SvOK(max_y)) {
			printf("[pathfinding reset error] bad max_y argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(max_steps) || SvTYPE(max_steps) >= SVt_PVAV || !SvOK(max_steps)) {
			printf("[pathfinding reset error] bad max_steps argument\n");
			XSRETURN_NO;
		}
		
		/* Get the weight_map data */
		weight_map_data = (char *) SvPVbyte_nolen (SvRV (weight_map));
		session->map_base_weight = weight_map_data;
		
		session->time_max = (unsigned long) SvUV (time_max);
		
		session->width = (int) SvUV (width);
		session->height = (int) SvUV (height);
		
		session->min_x = (int) SvUV (min_x);
		session->max_x = (int) SvUV (max_x);
		session->min_y = (int) SvUV (min_y);
		session->max_y = (int) SvUV (max_y);
		
		session->max_steps = (int) SvUV (max_steps);
		
		session->startX = (int) SvUV (startx);
		session->startY = (int) SvUV (starty);
		session->endX = (int) SvUV (destx);
		session->endY = (int) SvUV (desty);
		
		session->avoidWalls = (int) SvUV (avoidWalls);
		session->useManhattan = (int) SvUV (useManhattan);
		session->customWeights = (int) SvUV (customWeights);
		
		session->randomFactor = (int) SvUV (randomFactor);
		srand(time(0));
		
		session->exploring = 0;
		session->explore = 0;
	
		// Min and max check
		if (session->min_x >= session->width || session->min_y >= session->height || session->min_x < 0 || session->min_y < 0) {
			printf("[pathfinding reset error] Minimum coordinates %d %d are out of the map (size: %d x %d).\n", session->min_x, session->min_y, session->width, session->height);
			XSRETURN_NO;
		}
	
		if (session->max_x >= session->width || session->max_y >= session->height || session->max_x < 0 || session->max_y < 0) {
			printf("[pathfinding reset error] Maximum coordinates %d %d are out of the map (size: %d x %d).\n", session->max_x, session->max_y, session->width, session->height);
			XSRETURN_NO;
		}
	
		// Start check
		if (session->startX >= session->width || session->startY >= session->height || session->startX < 0 || session->startY < 0) {
			printf("[pathfinding reset error] Start coordinate %d %d is out of the map (size: %d x %d).\n", session->startX, session->startY, session->width, session->height);
			XSRETURN_NO;
		}
		
		if (session->map_base_weight[((session->startY * session->width) + session->startX)] == -1) {
			printf("[pathfinding reset error] Start coordinate %d %d is not a walkable cell.\n", session->startX, session->startY);
			XSRETURN_NO;
		}
	
		if (session->startX > session->max_x || session->startY > session->max_y || session->startX < session->min_x || session->startY < session->min_y) {
			printf("[pathfinding reset error] Start coordinate %d %d is out of the minimum and maximum coordinates (size: %d .. %d x %d .. %d).\n", session->startX, session->startY, session->min_x, session->max_x, session->min_y, session->max_y);
			XSRETURN_NO;
		}
	
		// End check
		if (session->endX >= session->width   || session->endY >= session->height   || session->endX < 0   || session->endY < 0) {
			printf("[pathfinding reset error] End coordinate %d %d is out of the map (size: %d x %d).\n", session->endX, session->endY, session->width, session->height);
			XSRETURN_NO;
		}
		
		if (session->map_base_weight[((session->endY * session->width) + session->endX)] == -1) {
			printf("[pathfinding reset error] End coordinate %d %d is not a walkable cell.\n", session->endX, session->endY);
			XSRETURN_NO;
		}
	
		if (session->endX > session->max_x || session->endY > session->max_y || session->endX < session->min_x || session->endY < session->min_y) {
			printf("[pathfinding reset error] End coordinate %d %d is out of the minimum and maximum coordinates (size: %d .. %d x %d .. %d).\n", session->endX, session->endY, session->min_x, session->max_x, session->min_y, session->max_y);
			XSRETURN_NO;
		}
		
		CalcPath_init(session);
		
		if (session->customWeights) {
			/* secondWeightMap should be a reference to an array */
			if (!SvROK(secondWeightMap)) {
				printf("[pathfinding reset error] secondWeightMap is not a reference\n");
				XSRETURN_NO;
			}
			
			if (SvTYPE(SvRV(secondWeightMap)) != SVt_PVAV) {
				printf("[pathfinding reset error] secondWeightMap is not an array reference\n");
				XSRETURN_NO;
			}
			
			if (!SvOK(secondWeightMap)) {
				printf("[pathfinding reset error] secondWeightMap is not defined\n");
				XSRETURN_NO;
			}
			
			AV *deref_secondWeightMap;
			I32 array_len;
			
			deref_secondWeightMap = (AV *) SvRV (secondWeightMap);
			array_len = av_len (deref_secondWeightMap);
			
			if (array_len == -1) {
				printf("[pathfinding reset error] secondWeightMap has no members\n");
				XSRETURN_NO;
			}
			
			SV **fetched;
			HV *hash;
		
			SV **ref_x;
			SV **ref_y;
			SV **ref_weight;
			
			IV x;
			IV y;
			
			I32 index;
			
			for (index = 0; index <= array_len; index++) {
				fetched = av_fetch (deref_secondWeightMap, index, 0);
			
				if (!SvROK(*fetched)) {
					printf("[pathfinding reset error] [secondWeightMap] member of array is not a reference\n");
					XSRETURN_NO;
				}
				
				if (SvTYPE(SvRV(*fetched)) != SVt_PVHV) {
					printf("[pathfinding reset error] [secondWeightMap] member of array is not a reference to a hash\n");
					XSRETURN_NO;
				}
				
				if (!SvOK(*fetched)) {
					printf("[pathfinding reset error] [secondWeightMap] member of array is not defined\n");
					XSRETURN_NO;
				}
				
				hash = (HV*) SvRV(*fetched);
				
				if (!hv_exists(hash, "x", 1)) {
					printf("[pathfinding reset error] [secondWeightMap] member of array does not contain the key 'x'\n");
					XSRETURN_NO;
				}
				
				ref_x = hv_fetch(hash, "x", 1, 0);
				
				if (SvROK(*ref_x)) {
					printf("[pathfinding reset error] [secondWeightMap] member of array 'x' key is a reference\n");
					XSRETURN_NO;
				}
				
				if (SvTYPE(*ref_x) >= SVt_PVAV) {
					printf("[pathfinding reset error] [secondWeightMap] member of array 'x' key is not a scalar\n");
					XSRETURN_NO;
				}
				
				if (!SvOK(*ref_x)) {
					printf("[pathfinding reset error] [secondWeightMap] member of array 'x' key is not defined\n");
					XSRETURN_NO;
				}
				
				x = SvIV(*ref_x);
				
				if (!hv_exists(hash, "y", 1)) {
					printf("[pathfinding reset error] [secondWeightMap] member of array does not contain the key 'y'\n");
					XSRETURN_NO;
				}
				
				ref_y = hv_fetch(hash, "y", 1, 0);
				
				if (SvROK(*ref_y)) {
					printf("[pathfinding reset error] [secondWeightMap] member of array 'y' key is a reference\n");
					XSRETURN_NO;
				}
				
				if (SvTYPE(*ref_y) >= SVt_PVAV) {
					printf("[pathfinding reset error] [secondWeightMap] member of array 'y' key is not a scalar\n");
					XSRETURN_NO;
				}
				
				if (!SvOK(*ref_y)) {
					printf("[pathfinding reset error] [secondWeightMap] member of array 'y' key is not defined\n");
					XSRETURN_NO;
				}
				
				y = SvIV(*ref_y);
				
				if (!hv_exists(hash, "weight", 6)) {
					printf("[pathfinding reset error] [secondWeightMap] member of array does not contain the key 'weight'\n");
					XSRETURN_NO;
				}
				
				ref_weight = hv_fetch(hash, "weight", 6, 0);
				
				if (SvROK(*ref_weight)) {
					printf("[pathfinding reset error] [secondWeightMap] member of array 'weight' key is a reference\n");
					XSRETURN_NO;
				}
				
				if (SvTYPE(*ref_weight) >= SVt_PVAV) {
					printf("[pathfinding reset error] [secondWeightMap] member of array 'weight' key is not a scalar\n");
					XSRETURN_NO;
				}
				
				if (!SvOK(*ref_weight)) {
					printf("[pathfinding reset error] [secondWeightMap] member of array 'weight' key is not defined\n");
					XSRETURN_NO;
				}
				
				unsigned int weight = SvIV(*ref_weight);
				
				unsigned long current = (y * session->width) + x;
				
				session->second_weight_map[current] = weight;
			}
		} else {
			if (SvOK(secondWeightMap)) {
				printf("[pathfinding reset error] secondWeightMap is defined while customWeights is 0\n");
				XSRETURN_NO;
			}
		}

int
PathFinding_run(session, solution_array)
		PathFinding session
		SV *solution_array
	PREINIT:
		int status;
	CODE:
		//printf("[PathFinding_run] start\n");
		
		/* Check for any missing arguments */
		if (!session || !solution_array) {
			printf("[PathFinding_run error] missing argument\n");
			XSRETURN_NO;
		}
		
		/* solution_array should be a reference to an array */
		if (!SvROK(solution_array)) {
			printf("[PathFinding_run error] solution_array is not a reference\n");
			XSRETURN_NO;
		}
		
		if (SvTYPE(SvRV(solution_array)) != SVt_PVAV) {
			printf("[PathFinding_run error] solution_array is not an array reference\n");
			XSRETURN_NO;
		}
		
		if (!SvOK(solution_array)) {
			printf("[PathFinding_run error] solution_array is not defined\n");
			XSRETURN_NO;
		}
		
		if (!session->initialized) {
			printf("[PathFinding_run error] You must call 'reset' before 'run'.\n");
			XSRETURN_NO;
		}
		
		if (session->exploring) {
			printf("[PathFinding_run error] You must call 'reset' before 'run' (maybe you called 'resetExploring' by accident?).\n");
			XSRETURN_NO;
		}

		status = CalcPath_pathStep (session);
		
		if (status < 0) {
			RETVAL = status;
		} else {
			AV *array;
			unsigned long size;

			size = (session->solution_size + 1);
 			array = (AV *) SvRV (solution_array);
			av_clear (array);
			av_extend (array, size);
			
			Node currentNode = session->currentMap[(session->endY * session->width) + session->endX];
			unsigned long current = session->solution_size;

			while (1)
			{
				HV * rh = (HV *)sv_2mortal((SV *)newHV());

				hv_store(rh, "x", 1, newSViv(currentNode.x), 0);

				hv_store(rh, "y", 1, newSViv(currentNode.y), 0);

				hv_store(rh, "g", 1, newSViv(currentNode.g), 0);

				av_store(array, current, newRV((SV *)rh));
				
				if (current == 0) {
					break;
				} else {
					currentNode = session->currentMap[currentNode.predecessor];
					current--;
				}
			}
			
			RETVAL = size;
		}
	OUTPUT:
		RETVAL

int
PathFinding_runcount(session)
		PathFinding session
	PREINIT:
		int status;
	CODE:
		/* Check for any missing arguments */
		if (!session) {
			printf("[PathFinding_runcount error] missing argument\n");
			XSRETURN_NO;
		}
		if (!session->initialized) {
			printf("[PathFinding_runcount error] You must call 'reset' before 'runcount'.\n");
			XSRETURN_NO;
		}
		if (session->exploring) {
			printf("[PathFinding_runcount error] You must call 'reset' before 'runcount' (maybe you called 'resetExploring' by accident?).\n");
			XSRETURN_NO;
		}
		status = CalcPath_pathStep (session);
		
		if (status < 0) {
			RETVAL = status;
		} else {
			RETVAL = (unsigned long) session->solution_size;
		}
	OUTPUT:
		RETVAL

void
PathFinding__resetExploring(session, weight_map, width, height, startx, starty, min_x, max_x, min_y, max_y)
		PathFinding session
		SV * weight_map
		SV * width
		SV * height
		SV * startx
		SV * starty
		SV * min_x
		SV * max_x
		SV * min_y
		SV * max_y
		
	PREINIT:
		char *weight_map_data = NULL;
	
	CODE:
		//printf("[PathFinding__resetExploring] start\n");
		
		/* If the object was already initiated, clean map memory */
		if (session->initialized) {
			free_initialized(session);
			session->initialized = 0;
		}
		
		/* Check for any missing arguments */
		if (!session || !weight_map || !width || !height || !startx || !starty || !min_x || !max_x || !min_y || !max_y) {
			printf("[pathfinding resetExploring error] missing argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(width) || SvTYPE(width) >= SVt_PVAV || !SvOK(width)) {
			printf("[pathfinding resetExploring error] bad width argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(height) || SvTYPE(height) >= SVt_PVAV || !SvOK(height)) {
			printf("[pathfinding resetExploring error] bad height argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(startx) || SvTYPE(startx) >= SVt_PVAV || !SvOK(startx)) {
			printf("[pathfinding resetExploring error] bad startx argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(starty) || SvTYPE(starty) >= SVt_PVAV || !SvOK(starty)) {
			printf("[pathfinding resetExploring error] bad starty argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(min_x) || SvTYPE(min_x) >= SVt_PVAV || !SvOK(min_x)) {
			printf("[pathfinding resetExploring error] bad min_x argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(max_x) || SvTYPE(max_x) >= SVt_PVAV || !SvOK(max_x)) {
			printf("[pathfinding resetExploring error] bad max_x argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(min_y) || SvTYPE(min_y) >= SVt_PVAV || !SvOK(min_y)) {
			printf("[pathfinding resetExploring error] bad min_y argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(max_y) || SvTYPE(max_y) >= SVt_PVAV || !SvOK(max_y)) {
			printf("[pathfinding resetExploring error] bad max_y argument\n");
			XSRETURN_NO;
		}
		
		/* Get the weight_map data */
		weight_map_data = (char *) SvPVbyte_nolen (SvRV (weight_map));
		session->map_base_weight = weight_map_data;
		
		session->width = (int) SvUV (width);
		session->height = (int) SvUV (height);
		
		session->min_x = (int) SvUV (min_x);
		session->max_x = (int) SvUV (max_x);
		session->min_y = (int) SvUV (min_y);
		session->max_y = (int) SvUV (max_y);
		
		session->startX = (int) SvUV (startx);
		session->startY = (int) SvUV (starty);
		
		session->exploring = 1;
		session->explore = 0;
	
		// Min and max check
		if (session->min_x >= session->width || session->min_y >= session->height || session->min_x < 0 || session->min_y < 0) {
			printf("[pathfinding reset error] Minimum coordinates %d %d are out of the map (size: %d x %d).\n", session->min_x, session->min_y, session->width, session->height);
			XSRETURN_NO;
		}
	
		if (session->max_x >= session->width || session->max_y >= session->height || session->max_x < 0 || session->max_y < 0) {
			printf("[pathfinding reset error] Maximum coordinates %d %d are out of the map (size: %d x %d).\n", session->max_x, session->max_y, session->width, session->height);
			XSRETURN_NO;
		}
	
		// Start check
		if (session->startX >= session->width || session->startY >= session->height || session->startX < 0 || session->startY < 0) {
			printf("[pathfinding reset error] Start coordinate %d %d is out of the map (size: %d x %d).\n", session->startX, session->startY, session->width, session->height);
			XSRETURN_NO;
		}
		
		if (session->map_base_weight[((session->startY * session->width) + session->startX)] == -1) {
			printf("[pathfinding reset error] Start coordinate %d %d is not a walkable cell.\n", session->startX, session->startY);
			XSRETURN_NO;
		}
	
		if (session->startX > session->max_x || session->startY > session->max_y || session->startX < session->min_x || session->startY < session->min_y) {
			printf("[pathfinding reset error] Start coordinate %d %d is out of the minimum and maximum coordinates (size: %d .. %d x %d .. %d).\n", session->startX, session->startY, session->min_x, session->max_x, session->min_y, session->max_y);
			XSRETURN_NO;
		}
		
		CalcPath_explore_init(session);

int
PathFinding_explore(session, explore_len, solution_array)
		PathFinding session
		SV * explore_len
		SV * solution_array
	PREINIT:
		int status;
	CODE:
		//printf("[PathFinding_explore] start\n");
		
		/* Check for any missing arguments */
		if (!session || !explore_len || !solution_array) {
			printf("[PathFinding_explore error] missing argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(explore_len) || SvTYPE(explore_len) >= SVt_PVAV || !SvOK(explore_len)) {
			printf("[PathFinding_explore error] bad explore_len argument\n");
			XSRETURN_NO;
		}
		
		/* solution_array should be a reference to an array */
		if (!SvROK(solution_array)) {
			printf("[PathFinding_explore error] solution_array is not a reference\n");
			XSRETURN_NO;
		}
		
		if (SvTYPE(SvRV(solution_array)) != SVt_PVAV) {
			printf("[PathFinding_explore error] solution_array is not an array reference\n");
			XSRETURN_NO;
		}
		
		if (!SvOK(solution_array)) {
			printf("[PathFinding_explore error] solution_array is not defined\n");
			XSRETURN_NO;
		}
		
		if (!session->initialized) {
			printf("[PathFinding_explore error] You must call 'resetExploring' before 'explore'.\n");
			XSRETURN_NO;
		}
		
		if (!session->exploring) {
			printf("[PathFinding_explore error] You must call 'resetExploring' before 'explore' (maybe you called 'reset' by accident?).\n");
			XSRETURN_NO;
		}
		
		long old_explore_len = session->explore;
		session->explore = (long) SvIV (explore_len);
		session->explore = session->explore*10;
		
		if (session->explore < 0) {
			printf("[PathFinding_explore error] explore_len %ld must be positive.\n", session->explore);
			XSRETURN_NO;
		}
		
		if (old_explore_len >= session->explore) {
			printf("[PathFinding_explore error] explore_len must always increase between calls (old %ld -> new: %ld).\n", old_explore_len, session->explore);
			XSRETURN_NO;
		}
		
		unsigned long old_exploredListSize = session->exploredListSize;
		status = CalcPath_explore (session);
		
		if (status < 0) {
			RETVAL = status;
		} else {
			AV *array;
			unsigned long size;
			
			unsigned long array_location;

			size = session->exploredListSize;
 			array = (AV *) SvRV (solution_array);
			av_clear (array);
			av_extend (array, size);
			
			unsigned long current = old_exploredListSize;
			
			Node currentNode;
			Node predecessor;

			while (current < size)
			{
				currentNode = session->currentMap[session->exploredList[current]];
				array_location = current - old_exploredListSize;
				
				HV * rh = (HV *)sv_2mortal((SV *)newHV());

				hv_store(rh, "x", 1, newSViv(currentNode.x), 0);

				hv_store(rh, "y", 1, newSViv(currentNode.y), 0);

				hv_store(rh, "g", 1, newSViv(currentNode.g), 0);

				hv_store(rh, "pc", 2, newSViv(currentNode.predecessorCount), 0);
				
				if (currentNode.x == session->startX && currentNode.y == session->startY) {
					hv_store(rh, "p", 1, newSViv(0), 0);
					hv_store(rh, "px", 2, newSViv(0), 0);
					hv_store(rh, "py", 2, newSViv(0), 0);
				} else {
					predecessor = session->currentMap[currentNode.predecessor];
					hv_store(rh, "p", 1, newSViv(1), 0);
					hv_store(rh, "px", 2, newSViv(predecessor.x), 0);
					hv_store(rh, "py", 2, newSViv(predecessor.y), 0);
				}

				av_store(array, array_location, newRV((SV *)rh));
				
				current++;
			}
			
			RETVAL = size;
		}
	OUTPUT:
		RETVAL

int
PathFinding_meeting(actor_session, target_session, max_explore_len, actor_speed, target_speed, dist)
		PathFinding actor_session
		PathFinding target_session
		SV * max_explore_len
		SV * actor_speed
		SV * target_speed
		SV * dist
	PREINIT:
		int actor_status;
		int target_status;
	CODE:
		//printf("[PathFinding_meeting] start\n");
		
		/* Check for any missing arguments */
		if (!actor_session || !target_session || !max_explore_len || !actor_speed || !target_speed || !dist) {
			printf("[PathFinding_meeting error] missing argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(max_explore_len) || SvTYPE(max_explore_len) >= SVt_PVAV || !SvOK(max_explore_len)) {
			printf("[PathFinding_meeting error] bad max_explore_len argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(actor_speed) || SvTYPE(actor_speed) >= SVt_PVAV || !SvOK(actor_speed)) {
			printf("[PathFinding_meeting error] bad actor_speed argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(target_speed) || SvTYPE(target_speed) >= SVt_PVAV || !SvOK(target_speed)) {
			printf("[PathFinding_meeting error] bad target_speed argument\n");
			XSRETURN_NO;
		}
		
		if (SvROK(dist) || SvTYPE(dist) >= SVt_PVAV || !SvOK(dist)) {
			printf("[PathFinding_meeting error] bad dist argument\n");
			XSRETURN_NO;
		}
		
		if (!actor_session->initialized) {
			printf("[PathFinding_meeting error] You must call 'resetExploring' before 'explore'.\n");
			XSRETURN_NO;
		}
		
		if (!actor_session->exploring) {
			printf("[PathFinding_meeting error] You must call 'resetExploring' before 'explore' (maybe you called 'reset' by accident?).\n");
			XSRETURN_NO;
		}
		
		if (!target_session->initialized) {
			printf("[PathFinding_meeting error] You must call 'resetExploring' before 'explore'.\n");
			XSRETURN_NO;
		}
		
		if (!target_session->exploring) {
			printf("[PathFinding_meeting error] You must call 'resetExploring' before 'explore' (maybe you called 'reset' by accident?).\n");
			XSRETURN_NO;
		}
		
		long l_max_explore_len = (long) SvIV (max_explore_len);
		
		if (l_max_explore_len < 0) {
			printf("[PathFinding_meeting error] max_explore_len %ld must be positive.\n", l_max_explore_len);
			XSRETURN_NO;
		}
		
		long l_actor_speed = (long) SvIV (actor_speed);
		long l_target_speed = (long) SvIV (target_speed);
		long run_dist = (long) SvIV (dist);
		run_dist = run_dist*10;
		
		long current_explore_len = 1;

		while (current_explore_len <= l_max_explore_len)
		{
			printf("[meeting explore loop %ld] start\n", current_explore_len);
			unsigned long old_exploredListSize = actor_session->exploredListSize;
			
			actor_session->explore = current_explore_len;
			actor_session->explore = actor_session->explore*10;
			actor_status = CalcPath_explore (actor_session);
			
			unsigned long size = actor_session->exploredListSize;
			
			if (size == old_exploredListSize) {
				printf("[PathFinding_meeting end 1] size did not increase after %ld iterations.\n", current_explore_len);
				XSRETURN_IV(-1);
			}
			
			unsigned long current_exploredList_index = old_exploredListSize;
			
			Node current_actor_Node;
			Node current_target_Node;

			while (current_exploredList_index < size)
			{
				unsigned long address = actor_session->exploredList[current_exploredList_index];
				current_actor_Node = actor_session->currentMap[address];
				
				unsigned long max_g = (((current_actor_Node.g * l_actor_speed)/l_target_speed)+run_dist);
				
				printf("[meeting exploredList loop %lu] %d %d - g %lu - maxg %lu - targetExp %ld\n", current_exploredList_index, current_actor_Node.x, current_actor_Node.y, current_actor_Node.g, max_g, target_session->explore);
				
				if (target_session->explore < max_g) {
					target_session->explore = max_g;
					target_status = CalcPath_explore (target_session);
				}
				
				current_target_Node = target_session->currentMap[address];
				
				if (current_target_Node.whichlist == 2) {
					if (current_target_Node.g >= max_g) {
						printf("[PathFinding_meeting end 2] Found %d %d at g %lu.\n", current_actor_Node.x, current_actor_Node.y, current_actor_Node.g);
						XSRETURN_IV(1);
					}
					
				} else {
					printf("[PathFinding_meeting end 3] Found %d %d at g %lu.\n", current_actor_Node.x, current_actor_Node.y, current_actor_Node.g);
					XSRETURN_IV(1);
				}
				
				current_exploredList_index++;
			}
			current_explore_len++;
		}
		printf("[PathFinding_meeting end 4] did not find cell after %ld iterations.\n", current_explore_len);
		XSRETURN_IV(0);
		
	OUTPUT:
		RETVAL

int
PathFinding_checkTile_XS(ix, iy, itile, iwidth, iheight, rawMap)
		SV * ix
		SV * iy
		SV * itile
		SV * iwidth
		SV * iheight
		SV * rawMap
		
	CODE:
		int x = (int) SvUV (ix);
		int y = (int) SvUV (iy);
		int tile = (int) SvUV (itile);
		int width = (int) SvUV (iwidth);
		int height = (int) SvUV (iheight);
		
		char * rawMap_data = (char *) SvPVbyte_nolen (SvRV (rawMap));
		
		RETVAL = checkTile_cpp(x, y, tile, width, height, rawMap_data);
		
	OUTPUT:
		RETVAL

int
PathFinding_checkLOS_XS(istart_x, istart_y, iend_x, iend_y, itile, iwidth, iheight, rawMap)
		SV * istart_x
		SV * istart_y
		SV * iend_x
		SV * iend_y
		SV * itile
		SV * iwidth
		SV * iheight
		SV * rawMap
		
	CODE:
		int start_x = (int) SvUV (istart_x);
		int start_y = (int) SvUV (istart_y);
		int end_x = (int) SvUV (iend_x);
		int end_y = (int) SvUV (iend_y);
		int tile = (int) SvUV (itile);
		int width = (int) SvUV (iwidth);
		int height = (int) SvUV (iheight);
		
		char * rawMap_data = (char *) SvPVbyte_nolen (SvRV (rawMap));
		
		RETVAL = checkLOS_cpp(start_x, start_y, end_x, end_y, tile, width, height, rawMap_data);
		
	OUTPUT:
		RETVAL

int
PathFinding_canAttack_XS(istart_x, istart_y, iend_x, iend_y, itile, iwidth, iheight, irange, iclientSight, rawMap)
		SV * istart_x
		SV * istart_y
		SV * iend_x
		SV * iend_y
		SV * itile
		SV * iwidth
		SV * iheight
		SV * irange
		SV * iclientSight
		SV * rawMap
		
	CODE:
		int start_x = (int) SvUV (istart_x);
		int start_y = (int) SvUV (istart_y);
		int end_x = (int) SvUV (iend_x);
		int end_y = (int) SvUV (iend_y);
		int tile = (int) SvUV (itile);
		int width = (int) SvUV (iwidth);
		int height = (int) SvUV (iheight);
		int range = (int) SvUV (irange);
		int clientSight = (int) SvUV (iclientSight);
		
		char * rawMap_data = (char *) SvPVbyte_nolen (SvRV (rawMap));
		
		RETVAL = canAttack_cpp(start_x, start_y, end_x, end_y, tile, width, height, range, clientSight, rawMap_data);
		
	OUTPUT:
		RETVAL

void
PathFinding_calcRectArea_XS(i_x, i_y, iradius, itile, iwidth, iheight, rawMap, solution_array)
		SV * i_x
		SV * i_y
		SV * iradius
		SV * itile
		SV * iwidth
		SV * iheight
		SV * rawMap
		SV * solution_array
		
	CODE:
		int x = (int) SvUV (i_x);
		int y = (int) SvUV (i_y);
		int radius = (int) SvUV (iradius);
		int tile = (int) SvUV (itile);
		int width = (int) SvUV (iwidth);
		int height = (int) SvUV (iheight);
		
		char * rawMap_data = (char *) SvPVbyte_nolen (SvRV (rawMap));
		
		int * limits = getSquareEdgesFromCoord_cpp(x, y, radius, width, height);
		int min_x = limits[0];
		int min_y = limits[1];
		int max_x = limits[2];
		int max_y = limits[3];
		
		AV *array;
 		array = (AV *) SvRV (solution_array);
		av_clear (array);
		
		int offset;
		
		int value;
		
		int size;
		
		x = min_x;
		y = min_y;
		offset = (y * width) + x;
		size = 0;
		
		while (x < max_x) {
			value = rawMap_data[offset];
			if (value & tile) {
				av_extend (array, (size+1));
				HV * rh = (HV *)sv_2mortal((SV *)newHV());

				hv_store(rh, "x", 1, newSViv(x), 0);
				hv_store(rh, "y", 1, newSViv(y), 0);

				av_store(array, size, newRV((SV *)rh));
				size++;
			}
			offset++;
			x++;
		}
		
		while (y < max_y) {
			value = rawMap_data[offset];
			if (value & tile) {
				av_extend (array, (size+1));
				HV * rh = (HV *)sv_2mortal((SV *)newHV());

				hv_store(rh, "x", 1, newSViv(x), 0);
				hv_store(rh, "y", 1, newSViv(y), 0);

				av_store(array, size, newRV((SV *)rh));
				size++;
			}
			offset += width;
			y++;
		}
		
		while (x > min_x) {
			value = rawMap_data[offset];
			if (value & tile) {
				av_extend (array, (size+1));
				HV * rh = (HV *)sv_2mortal((SV *)newHV());

				hv_store(rh, "x", 1, newSViv(x), 0);
				hv_store(rh, "y", 1, newSViv(y), 0);

				av_store(array, size, newRV((SV *)rh));
				size++;
			}
			offset--;
			x--;
		}
		
		while (y > min_y) {
			value = rawMap_data[offset];
			if (value & tile) {
				av_extend (array, (size+1));
				HV * rh = (HV *)sv_2mortal((SV *)newHV());

				hv_store(rh, "x", 1, newSViv(x), 0);
				hv_store(rh, "y", 1, newSViv(y), 0);

				av_store(array, size, newRV((SV *)rh));
				size++;
			}
			offset -= width;
			y--;
		}

int
PathFinding_checkPathFree_XS(istart_x, istart_y, iend_x, iend_y, itile, iwidth, iheight, rawMap)
		SV * istart_x
		SV * istart_y
		SV * iend_x
		SV * iend_y
		SV * itile
		SV * iwidth
		SV * iheight
		SV * rawMap
		
	CODE:
		int start_x = (int) SvUV (istart_x);
		int start_y = (int) SvUV (istart_y);
		int end_x = (int) SvUV (iend_x);
		int end_y = (int) SvUV (iend_y);
		int tile = (int) SvUV (itile);
		int width = (int) SvUV (iwidth);
		int height = (int) SvUV (iheight);
		
		char * rawMap_data = (char *) SvPVbyte_nolen (SvRV (rawMap));
		
		RETVAL = checkPathFree_cpp(start_x, start_y, end_x, end_y, tile, width, height, rawMap_data);
		
	OUTPUT:
		RETVAL

void
PathFinding_getSquareEdgesFromCoord_XS(i_x, i_y, iradius, iwidth, iheight, solution_array)
		SV * i_x
		SV * i_y
		SV * iradius
		SV * iwidth
		SV * iheight
		SV * solution_array
		
	CODE:
		int x = (int) SvUV (i_x);
		int y = (int) SvUV (i_y);
		int radius = (int) SvUV (iradius);
		int width = (int) SvUV (iwidth);
		int height = (int) SvUV (iheight);
		
		int * limits = getSquareEdgesFromCoord_cpp(x, y, radius, width, height);
		
		AV *array;
 		array = (AV *) SvRV (solution_array);
		av_clear (array);
		av_extend (array, 4);
		
		av_store(array, 0, newSViv(limits[0]));
		av_store(array, 1, newSViv(limits[1]));
		av_store(array, 2, newSViv(limits[2]));
		av_store(array, 3, newSViv(limits[3]));

int
PathFinding_blockDistance_XS(istart_x, istart_y, iend_x, iend_y)
		SV * istart_x
		SV * istart_y
		SV * iend_x
		SV * iend_y
		
	CODE:
		int start_x = (int) SvUV (istart_x);
		int start_y = (int) SvUV (istart_y);
		int end_x = (int) SvUV (iend_x);
		int end_y = (int) SvUV (iend_y);
		
		RETVAL = blockDistance_cpp(start_x, start_y, end_x, end_y);
		
	OUTPUT:
		RETVAL

int
PathFinding_getClientDist_XS(istart_x, istart_y, iend_x, iend_y)
		SV * istart_x
		SV * istart_y
		SV * iend_x
		SV * iend_y
		
	CODE:
		int start_x = (int) SvUV (istart_x);
		int start_y = (int) SvUV (istart_y);
		int end_x = (int) SvUV (iend_x);
		int end_y = (int) SvUV (iend_y);
		
		RETVAL = getClientDist_cpp(start_x, start_y, end_x, end_y);
		
	OUTPUT:
		RETVAL

int
PathFinding_get_client_easy_solution_XS(istart_x, istart_y, iend_x, iend_y, solution_array)
		SV * istart_x
		SV * istart_y
		SV * iend_x
		SV * iend_y
		SV * solution_array
		
	CODE:
		int start_x = (int) SvUV (istart_x);
		int start_y = (int) SvUV (istart_y);
		int end_x = (int) SvUV (iend_x);
		int end_y = (int) SvUV (iend_y);
		
		int size = blockDistance_cpp(start_x, start_y, end_x, end_y);
		
		AV *array;
 		array = (AV *) SvRV (solution_array);
		av_clear (array);
		av_extend (array, size);
		
		int stepType;
		int g = 0;
		int i = 0;

		while (1) {
			HV * rh = (HV *)sv_2mortal((SV *)newHV());

			hv_store(rh, "x", 1, newSViv(start_x), 0);
			hv_store(rh, "y", 1, newSViv(start_y), 0);
			hv_store(rh, "g", 1, newSViv(g), 0);

			av_store(array, i, newRV((SV *)rh));
			i++;

			stepType = 0;
			if (start_x < end_x) {
				start_x++;
				stepType++;
			} else if (start_x > end_x) {
				start_x--;
				stepType++;
			}
			if (start_y < end_y) {
				start_y++;
				stepType++;
			} else if (start_y > end_y) {
				start_y--;
				stepType++;
			}

			if (stepType == 1) {
				g += 10;
			} else if (stepType == 2) {
				g += 14;
			} else if (stepType == 0) {
				break;
			}
		}
		
		RETVAL = 1;
		
	OUTPUT:
		RETVAL
