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

unsigned int*
calcKey (Node* node, unsigned int k)
{
	static unsigned int key[2];
    key[1] = ((node->g > node->rhs) ? node->rhs : node->g);
	key[0] = key[1] + node->h + k;
    return key;
}

int 
heuristic_cost_estimate (int currentX, int currentY, int startX, int startY, int avoidWalls)
{
    int xDistance = abs(currentX - startX);
    int yDistance = abs(currentY - startY);
    
    int hScore = (ORTOGONAL * (xDistance + yDistance)) + ((DIAGONAL - (2 * ORTOGONAL)) * ((xDistance > yDistance) ? yDistance : xDistance));
    
    if (avoidWalls) {
        hScore += (((xDistance > yDistance) ? xDistance : yDistance) * 10);
    }
    
    return hScore;
}

//Openlist is a binary heap of min-heap type

void 
openListAdd (CalcPath_session *session, Node* node)
{
	int currentIndex = session->openListSize;
    session->openList[currentIndex] = node->nodeAdress;
    node->openListIndex = currentIndex;
	node->isInOpenList = 1;
	session->openListSize++;
	
	int nextIndex = PARENT(currentIndex);
	
	unsigned int Temporary;
	Node* nextNode;
	
    while (nextIndex >= 0) {
		nextNode = &session->currentMap[session->openList[nextIndex]];
		if (nextNode->key1 > node->key1 || (nextNode->key1 == node->key1 && nextNode->key2 > node->key2)) {
			Temporary = session->openList[currentIndex];
			
            session->openList[currentIndex] = session->openList[nextIndex];
            nextNode->openListIndex = currentIndex;
			
            session->openList[nextIndex] = Temporary;
            node->openListIndex = nextIndex;
			
			currentIndex = nextIndex;
			nextIndex = PARENT(currentIndex);
        } else { break; }
	}
}

void 
openListRemove (CalcPath_session *session, Node* node)
{
	int currentIndex = node->openListIndex;
	node->isInOpenList = 0;
	session->openListSize--;
	session->openList[currentIndex] = session->openList[session->openListSize];
    session->currentMap[session->openList[currentIndex]].openListIndex = currentIndex;
	
	node = &session->currentMap[session->openList[currentIndex]];
	
	int nextIndex = 0;
	
	unsigned int Temporary;
	Node* nextNode;
	
	int rightChild = RCHILD(currentIndex);
	int leftChild = LCHILD(currentIndex);
	
	while (leftChild < session->openListSize - 2) {
		
		//There are 2 children
		if (rightChild <= session->openListSize - 2) {
			if (session->currentMap[session->openList[rightChild]].key1 > session->currentMap[session->openList[leftChild]].key1 || (session->currentMap[session->openList[rightChild]].key1 == session->currentMap[session->openList[leftChild]].key1 && session->currentMap[session->openList[rightChild]].key2 > session->currentMap[session->openList[leftChild]].key2)) {
				nextIndex = leftChild;
			} else {
				nextIndex = rightChild;
			}
		
		//There is 1 children
		} else {
			if (leftChild <= session->openListSize - 2) {
				nextIndex = leftChild;
			} else {
				break;
			}
		}
		
		nextNode = &session->currentMap[session->openList[nextIndex]];
		
		if (node->key1 > nextNode->key1 || (node->key1 == nextNode->key1 && node->key2 > nextNode->key2)) {
			Temporary = session->openList[currentIndex];
			
			session->openList[currentIndex] = session->openList[nextIndex];
			nextNode->openListIndex = currentIndex;
			
			session->openList[nextIndex] = Temporary;
			node->openListIndex = nextIndex;
			
			currentIndex = nextIndex;
			rightChild = RCHILD(currentIndex);
			leftChild = LCHILD(currentIndex);
		} else { break; }
	}
}

void 
reajustOpenListItem (CalcPath_session *session, Node* node, unsigned int newkey1, unsigned int newkey2)
{
    int currentIndex = node->openListIndex;
	if (node->key1 > newkey1 || (node->key1 == newkey1 && node->key2 > newkey2)) {
		node->key1 = newkey1;
		node->key2 = newkey2;
		int nextIndex = PARENT(currentIndex);
	
		unsigned int Temporary;
		Node* nextNode;

		while (nextIndex >= 0) {
			nextNode = &session->currentMap[session->openList[nextIndex]];
			if (nextNode->key1 > node->key1 || (nextNode->key1 == node->key1 && nextNode->key2 > node->key2)) {
				Temporary = session->openList[currentIndex];

				session->openList[currentIndex] = session->openList[nextIndex];
				nextNode->openListIndex = currentIndex;

				session->openList[nextIndex] = Temporary;
				node->openListIndex = nextIndex;

				currentIndex = nextIndex;
				nextIndex = PARENT(currentIndex);
			} else { break; }
		}
	} else {
		int nextIndex = 0;

		unsigned int Temporary;
		Node* nextNode;

		int rightChild = RCHILD(currentIndex);
		int leftChild = LCHILD(currentIndex);

		while (leftChild < session->openListSize - 2) {

			//There are 2 children
			if (rightChild <= session->openListSize - 2) {
				if (session->currentMap[session->openList[rightChild]].key1 > session->currentMap[session->openList[leftChild]].key1 || (session->currentMap[session->openList[rightChild]].key1 == session->currentMap[session->openList[leftChild]].key1 && session->currentMap[session->openList[rightChild]].key2 > session->currentMap[session->openList[leftChild]].key2)) {
					nextIndex = leftChild;
				} else {
					nextIndex = rightChild;
				}

			//There is 1 children
			} else {
				if (leftChild <= session->openListSize - 2) {
					nextIndex = leftChild;
				} else {
					break;
				}
			}

			nextNode = &session->currentMap[session->openList[nextIndex]];

			if (node->key1 > nextNode->key1 || (node->key1 == nextNode->key1 && node->key2 > nextNode->key2)) {
				Temporary = session->openList[currentIndex];

				session->openList[currentIndex] = session->openList[nextIndex];
				nextNode->openListIndex = currentIndex;

				session->openList[nextIndex] = Temporary;
				node->openListIndex = nextIndex;

				currentIndex = nextIndex;
				rightChild = RCHILD(currentIndex);
				leftChild = LCHILD(currentIndex);
			} else { break; }
		}
	}
}

Node* 
openListGetLowest (CalcPath_session *session)
{
    Node* lowestNode = &session->currentMap[session->openList[0]];
    return lowestNode;
}

void 
updateNode (CalcPath_session *session, Node* node)
{
	if (node->g != node->rhs) {
		if (node->isInOpenList) {
			unsigned int* keys = calcKey(node, session->k);
			reajustOpenListItem(session, node, keys[0], keys[1]);
		} else {
			unsigned int* keys = calcKey(node, session->k);
			node->key1 = keys[0];
			node->key2 = keys[1];
			openListAdd (session, node);
		}
		
	} else if (node->isInOpenList) {
		openListRemove(session, node);
	}
}

void 
reconstruct_path(CalcPath_session *session, Node* goal, Node* start)
{
	Node* currentNode = start;
	
	session->solution_size = 0;
	while (currentNode->nodeAdress != goal->nodeAdress)
    {
        currentNode = &session->currentMap[currentNode->sucessor];
        session->solution_size++;
    }
}

int 
CalcPath_pathStep (CalcPath_session *session)
{
	
	if (!session->initialized) {
		return -2;
	}
	
	Node* start = &session->currentMap[((session->startY * session->width) + session->startX)];
	Node* goal = &session->currentMap[((session->endY * session->width) + session->endX)];
	
	unsigned int* keys;
	
	if (!session->run) {
		session->run = 1;
		session->openListSize = 0;
		session->openList = (unsigned int*) malloc((session->height * session->width) * sizeof(unsigned int));
		
		goal->h = heuristic_cost_estimate(goal->x, goal->y, start->x, start->y, session->avoidWalls);
		keys = calcKey(goal, session->k);
		goal->key1 = keys[0];
		goal->key2 = keys[1];
		openListAdd (session, goal);
	}
	
	Node* currentNode;
	Node* neighbor;
	
	int i;
	int j;
	int current;
	int distanceFromCurrent;
	
	unsigned long timeout = (unsigned long) GetTickCount();
	int loop = 0;
	
    while (1) {
		
		// No path exists
		if (session->openListSize == 0) {
			return -1;
		}
		
		// Path found
		if (start->key1 > session->currentMap[session->openList[0]].key1 || (start->key1 == session->currentMap[session->openList[0]].key1 && start->key2 > session->currentMap[session->openList[0]].key2)) {
			reconstruct_path(session, goal, start);
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
		
		keys = calcKey(currentNode, session->k);
		
		if (keys[0] > currentNode->key1 || (keys[0] == currentNode->key1 && keys[1] > currentNode->key2)) {
			reajustOpenListItem(session, currentNode, keys[0], keys[1]);
			
		} else if (currentNode->g > currentNode->rhs) {
			currentNode->g = currentNode->rhs;
			openListRemove(session, currentNode);
			
			for (i = -1; i <= 1; i++)
			{
				for (j = -1; j <= 1; j++)
				{
					if (i == 0 && j == 0) { continue; }
					int x = currentNode->x + i;
					int y = currentNode->y + j;
					
					if (x >= session->width || y >= session->height || x < 0 || y < 0) { continue; }
	
					int current = (y * session->width) + x;

					if (session->map[current] == 0) { continue; }

					neighbor = &session->currentMap[current];
					
					int distanceFromCurrent;
					if (i != 0 && j != 0) {
						if (session->map[(currentNode->y * session->width) + neighbor->x] == 0 || session->map[(neighbor->y * session->width) + currentNode->x] == 0){ continue; }
						distanceFromCurrent = DIAGONAL;
					} else {
						distanceFromCurrent = ORTOGONAL;
					}
					if (session->avoidWalls) {
						distanceFromCurrent += session->map[neighbor->nodeAdress];
					}
					
					if (neighbor->h == 0) {
						neighbor->h = heuristic_cost_estimate(neighbor->x, neighbor->y, start->x, start->y, session->avoidWalls);
					}
					
					if (neighbor->nodeAdress != goal->nodeAdress && neighbor->rhs > (currentNode->g + distanceFromCurrent)) {
						neighbor->sucessor = currentNode->nodeAdress;
						neighbor->rhs = currentNode->g + distanceFromCurrent;
						updateNode(session, neighbor);
					}
				}
			}
			
			
		} else {
			updateNode(session, currentNode);
			
			currentNode->g = INFINITE;
			for (i = -1; i <= 1; i++)
			{
				for (j = -1; j <= 1; j++)
				{
					if (i == 0 && j == 0) { continue; }
					int x = currentNode->x + i;
					int y = currentNode->y + j;
					
					if (x >= session->width || y >= session->height || x < 0 || y < 0) { continue; }
	
					int current = (y * session->width) + x;

					if (session->map[current] == 0) { continue; }

					neighbor = &session->currentMap[current];
					
					int distanceFromCurrent;
					if (i != 0 && j != 0) {
						if (session->map[(currentNode->y * session->width) + neighbor->x] == 0 || session->map[(neighbor->y * session->width) + currentNode->x] == 0){ continue; }
						distanceFromCurrent = DIAGONAL;
					} else {
						distanceFromCurrent = ORTOGONAL;
					}
					if (session->avoidWalls) {
						distanceFromCurrent += session->map[neighbor->nodeAdress];
					}
					
					if (neighbor->nodeAdress != goal->nodeAdress && neighbor->sucessor == currentNode->nodeAdress) {
						Node lowest = get_lowest_neighbor_rhs(session, *neighbor);
						neighbor->sucessor = lowest.nodeAdress;
						
						int distanceFromCurrent2;
						if (lowest.y != neighbor->y && lowest.x != neighbor->x) {
							if (session->map[(lowest.y * session->width) + neighbor->x] == 0 || session->map[(neighbor->y * session->width) + lowest.x] == 0){ continue; }
							distanceFromCurrent2 = DIAGONAL;
						} else {
							distanceFromCurrent2 = ORTOGONAL;
						}
						if (session->avoidWalls) {
							distanceFromCurrent2 += session->map[neighbor->nodeAdress];
						}
						
						neighbor->rhs = lowest.g + distanceFromCurrent2;
					}
					updateNode(session, neighbor);
				}
			}
		}
	}
}

Node
get_lowest_neighbor_rhs (CalcPath_session *session, Node currentNode)
{
	Node nextNode;
	nextNode.rhs = INFINITE;
	
	Node neighbor;
	int i;
	for (i = -1; i <= 1; i++)
	{
		int j;
		for (j = -1; j <= 1; j++)
		{
			if (i == 0 && j == 0){ continue; }
			int x = currentNode.x + i;
			int y = currentNode.y + j;
				
			if (x >= session->width || y >= session->height || x < 0 || y < 0) { continue; }

			int current = (y * session->width) + x;

			if (session->map[current] == 0) { continue; }
			
			neighbor = session->currentMap[current];
			
			int distanceFromCurrent;
			if (i != 0 && j != 0) {
				if (session->map[(currentNode.y * session->width) + neighbor.x] == 0 || session->map[(neighbor.y * session->width) + currentNode.x] == 0){ continue; }
				distanceFromCurrent = DIAGONAL;
			} else {
				distanceFromCurrent = ORTOGONAL;
			}
			if (session->avoidWalls) {
				distanceFromCurrent += session->map[neighbor.nodeAdress];
			}
			
			if (neighbor.rhs < nextNode.rhs) {
				nextNode = neighbor;
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
			session->currentMap[current].nodeAdress = current;
			session->currentMap[current].g = INFINITE;
			session->currentMap[current].rhs = INFINITE;
		}
	}
	
	session->currentMap[(session->endY * session->width) + session->endX].rhs = 0;
	
	session->k = 0;
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
