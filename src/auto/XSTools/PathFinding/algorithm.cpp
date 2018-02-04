#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include "algorithm.h"

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#define DIAGONAL 14
#define ORTOGONAL 10
#define LCHILD(currentIndex) 2 * currentIndex + 1
#define RCHILD(currentIndex) 2 * currentIndex + 2
#define PARENT(currentIndex) (int)floor((currentIndex - 1) / 2)
#define INFINITE  10000000

#ifdef WIN32
	#include <windows.h>
#else
	#include <sys/time.h>
	static unsigned long
	GetTickCount ()
	{
		struct timeval tv;
		gettimeofday (&tv, (struct timezone *) NULL);
		return (tv.tv_sec * 1000) + (tv.tv_usec / 1000);
	}
#endif /* WIN32 */


/*******************************************/


// Create a new, empty pathfinding session.
// You must initialize it with CalcPath_init()
CalcPath_session *
CalcPath_new ()
{
	CalcPath_session *session;

	session = (CalcPath_session*) malloc (sizeof (CalcPath_session));
	
	session->initialized = 0;
	session->run = 0;
	
	return session;
}

void
calcKey (Node* infoAdress)
{
	infoAdress->key[1] = ((infoAdress->g > infoAdress->rhs) ? infoAdress->rhs : infoAdress->g);
	infoAdress->key[0] = infoAdress->key[1] + infoAdress->h;
}

int
first_key_bigger_than_second_key (int first[2], int second[2])
{
	if (first[0] > second[0] || (first[0] == second[0] && first[1] > second[1])) {
		return 1;
	}
	return 0;
}

int 
heuristic_cost_estimate (int currentX, int currentY, int goalX, int goalY, int avoidWalls)
{
    int xDistance = abs(currentX - goalX);
    int yDistance = abs(currentY - goalY);
    
    int hScore = (ORTOGONAL * (xDistance + yDistance)) + ((DIAGONAL - (2 * ORTOGONAL)) * ((xDistance > yDistance) ? yDistance : xDistance));
    
    if (avoidWalls) {
        hScore += (((xDistance > yDistance) ? xDistance : yDistance) * 10);
    }
    
    return hScore;
}

//Openlist is a binary heap of min-heap type

void 
openListAdjustUp (CalcPath_session *session, Node* infoAdress)
{
	int currentIndex = infoAdress->openListIndex;
	TypeList Temporary;
    while (PARENT(currentIndex) >= 0) {
		if (first_key_bigger_than_second_key(session->openList[PARENT(currentIndex)].key, session->openList[currentIndex].key)) {
            Temporary = session->openList[currentIndex];
            session->openList[currentIndex] = session->openList[PARENT(currentIndex)];
            session->currentMap[(session->openList[currentIndex].y * session->width) + session->openList[currentIndex].x].openListIndex = currentIndex;
            session->openList[PARENT(currentIndex)] = Temporary;
            infoAdress->openListIndex = PARENT(currentIndex);
            currentIndex = PARENT(currentIndex);
        } else { break; }
    }
}

void 
openListAdjustDown (CalcPath_session *session, Node* infoAdress)
{
	int currentIndex = infoAdress->openListIndex;
	TypeList Temporary;
	int lowestChildIndex = 0;
	while (LCHILD(currentIndex) < session->openListSize - 2) {
		//There are 2 children
		if (RCHILD(currentIndex) <= session->openListSize - 2) {
			if (first_key_bigger_than_second_key(session->openList[RCHILD(currentIndex)].key, session->openList[LCHILD(currentIndex)].key)) {
				lowestChildIndex = LCHILD(currentIndex);
			} else {
				lowestChildIndex = RCHILD(currentIndex);
			}
		} else {
			//There is 1 children
			if (LCHILD(currentIndex) <= session->openListSize - 2) {
				lowestChildIndex = LCHILD(currentIndex);
			} else {
				break;
			}
		}
		if (first_key_bigger_than_second_key(session->openList[currentIndex].key, session->openList[lowestChildIndex].key)) {
			Temporary = session->openList[currentIndex];
			session->openList[currentIndex] = session->openList[lowestChildIndex];
			session->currentMap[(session->openList[currentIndex].y * session->width) + session->openList[currentIndex].x].openListIndex = currentIndex;
			session->openList[lowestChildIndex] = Temporary;
			session->currentMap[(session->openList[lowestChildIndex].y * session->width) + session->openList[lowestChildIndex].x].openListIndex = lowestChildIndex;
			currentIndex = lowestChildIndex;
		} else { break; }
	}
}

void 
openListAdd (CalcPath_session *session, Node* infoAdress)
{
	int currentIndex = session->openListSize;
    session->openList[currentIndex].x = infoAdress->x;
    session->openList[currentIndex].y = infoAdress->y;
    session->openList[currentIndex].key = infoAdress->key;
    infoAdress->openListIndex = currentIndex;
	infoAdress->isInOpenList = 1;
	session->openListSize++;
    openListAdjustUp(session, infoAdress);
}

void 
openListRemove (CalcPath_session *session, Node* infoAdress)
{
	int currentIndex = infoAdress->openListIndex;
	session->openList[currentIndex] = session->openList[session->openListSize-1];
    session->currentMap[(session->openList[currentIndex].y * session->width) + session->openList[currentIndex].x].openListIndex = currentIndex;
	infoAdress->isInOpenList = 0;
	session->openListSize--;
    openListAdjustDown(session, infoAdress);
}

void 
reajustOpenListItem (CalcPath_session *session, Node* infoAdress, int oldkey[2])
{
    int currentIndex = infoAdress->openListIndex;
	session->openList[currentIndex].key = infoAdress->key;
	if (first_key_bigger_than_second_key(oldkey, infoAdress->key)) {
		openListAdjustUp(session, infoAdress);
	} else {
		openListAdjustDown(session, infoAdress);
	}
}

Node* 
openListGetLowest (CalcPath_session *session)
{
    Node* lowestNode = &session->currentMap[(session->openList[0].y * session->width) + session->openList[0].x];
    openListRemove(session, lowestNode);
    return lowestNode;
}

int 
CalcPath_pathStep (CalcPath_session *session)
{
	
	if (!session->initialized) {
		return -2;
	}
	
	Node* start = &session->currentMap[((session->startY * session->width) + session->startX)];
	Node* goal = &session->currentMap[((session->endY * session->width) + session->endX)];
	
	if (!session->run) {
		session->run = 1;
		session->size = session->height * session->width;
		session->openListSize = 0;
		session->openList = (TypeList*) malloc(session->size * sizeof(TypeList));
		
		calcKey(start);
		openListAdd (session, start);
	}
	
	Node* currentNode;
	Node* infoAdress;
	int indexNeighbor = 0;
	int nodeList;
	
	unsigned long timeout = (unsigned long) GetTickCount();
	int loop = 0;
	
    while (1) {
		
		// No path exists
		if (session->openListSize == 0) {
			return -1;
		}
		
		// Path found
		if (first_key_bigger_than_second_key(goal->key, session->openList[0].key) || goal->g != goal->rhs) {
			return 1;
		}
		
		loop++;
		if (loop == 100) {
			if (GetTickCount() - timeout > session->time_max) {
				return 0;
			} else
				loop = 0;
		}
		
        // get lowest key score member of openlist and delete it from it, shrinks openListSize
		currentNode = openListGetLowest (session);
		
		if (currentNode->g > currentNode->rhs) {
			currentNode->g = currentNode->rhs;
		} else {
			currentNode->g = INFINITE;
		}
		
		int i;
		for (i = -1; i <= 1; i++)
		{
			int j;
			for (j = -1; j <= 1; j++)
			{
				if (i == 0 && j == 0){ continue; }
				unsigned int x = currentNode->x + i;
				unsigned int y = currentNode->y + j;
				
				if (x >= session->width || y >= session->height || x < 0 || y < 0){ continue; }
				
				int current = (y * session->width) + x;
				
				if (session->map[current] == 0){ continue; }
				
				infoAdress = &session->currentMap[current];
				
				int distanceFromCurrent;
				if (i != 0 && j != 0) {
				   if (session->map[(currentNode->y * session->width) + x] == 0 || session->map[(y * session->width) + currentNode->x] == 0){ continue; }
					distanceFromCurrent = DIAGONAL;
				} else {
					distanceFromCurrent = ORTOGONAL;
				}
				if (session->avoidWalls) {
					distanceFromCurrent += session->map[current];
				}
				
				infoAdress->h = heuristic_cost_estimate(infoAdress->x, infoAdress->y, session->endX, session->endY, session->avoidWalls);
				
				if (session->startY != y || session->startX != x) {
					infoAdress->rhs = currentNode->g + distanceFromCurrent;
				}
				
				if (infoAdress->isInOpenList) {
					openListRemove(session, infoAdress);
				}
				
				if (infoAdress->g != infoAdress->rhs) {
					calcKey(infoAdress);
					openListAdd (session, infoAdress);
				}
			}
		}
	}
}

Node
get_lowest_neighbor_sum_node (CalcPath_session *session, Node currentNode)
{
	Node nextNode;
	nextNode.rhs = INFINITE;
	
	Node* infoAdress;
	int i;
	for (i = -1; i <= 1; i++)
	{
		int j;
		for (j = -1; j <= 1; j++)
		{
			if (i == 0 && j == 0){ continue; }
			
			infoAdress = &session->currentMap[((currentNode.y + j) * session->width) + (currentNode.x + i)];
			
			if (infoAdress->rhs < nextNode.rhs) {
				nextNode = infoAdress;
			}
		}
	}
	return nextNode;
}

// Create a new pathfinding session, or reset an existing session.
// Resetting is preferred over destroying and creating, because it saves
// unnecessary memory allocations, thus improving performance.
CalcPath_session *
CalcPath_init (CalcPath_session *session)
{
	
	unsigned int x = 0;
	unsigned int y = 0;
	
	int current;
	for (y = 0; y < session->height; y++) {
		for (x = 0; x < session->width; x++) {
			current = (y * session->width) + x;
			session->currentMap[current].x = x;
			session->currentMap[current].y = y;
			session->currentMap[current].isInOpenList = 0;
			session->currentMap[current].g = INFINITE;
			session->currentMap[current].rhs = INFINITE;
		}
	}
	
	session->currentMap[(session->startY * session->width) + session->startX].rhs = 0;
	
	session->initialized = 1;
	
	return session;
}

void
CalcPath_destroy (CalcPath_session *session)
{

	if (session->initialized) {
		free(session->currentMap);
	}
	
	if (session->run) {
		free(session->openList);
	}

	free (session);
}

#ifdef __cplusplus
}
#endif /* __cplusplus */
