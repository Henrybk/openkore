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
calcKey (Node* node, unsigned int startX, unsigned int startY, bool avoidWalls, unsigned int k)
{
	static unsigned int key[2];
	
    key[1] = ((node->g > node->rhs) ? node->rhs : node->g);
	
	unsigned short h = heuristic_cost_estimate(node->x, node->y, startX, startY, avoidWalls);
	
	key[0] = key[1] + h + k;
	
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
	node->openListIndex = 0;
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
	
	// Node got ligher, so we ajust it up
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
	
	// Node got heavier, so we ajust it down
	} else {
		// Dont really know abut the 2 next lines
		node->key1 = newkey1;
		node->key2 = newkey2;
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
			unsigned int* keys = calcKey(node, session->startX, session->startY, session->avoidWalls, session->k);
			reajustOpenListItem(session, node, keys[0], keys[1]);
		} else {
			unsigned int* keys = calcKey(node, session->startX, session->startY, session->avoidWalls, session->k);
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
	
	
	printf("[test] pathstep 05\n");
	
	printf("[test] Path from %d %d to %d %d\n", session->startX, session->startY, session->endX, session->endY);
	
	session->solution_size = 0;
	while (currentNode->nodeAdress != goal->nodeAdress && session->solution_size < 20)
    {
		printf("[test] pathstep 05.1 || size: %d || node %d %d || sucessor %d %d\n", session->solution_size, currentNode->x, currentNode->y, session->currentMap[currentNode->sucessor].x, session->currentMap[currentNode->sucessor].y);
        currentNode = &session->currentMap[currentNode->sucessor];
		session->solution_size++;
    }
	
	printf("[test] pathstep 06\n");
}

void 
updateNode (CalcPath_session *session, Node* node)
{
	if (node->g != node->rhs) {
		if (node->isInOpenList) {
			int* keys = calcKey(node, session->k);
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
	
	printf("[test] pathstep 00-3\n");
	if (!session->initialized) {
		return -2;
	}
	printf("[test] pathstep 00-4\n");
	Node* start = &session->currentMap[((session->startY * session->width) + session->startX)];
	printf("[test] pathstep 00-5\n");
	Node* goal = &session->currentMap[((session->endY * session->width) + session->endX)];
	
	printf("[test] pathstep 00\n");
	
	unsigned int* keys;
	
	if (!session->run) {
		session->run = 1;
		session->openListSize = 0;
		session->openList = (unsigned int*) malloc((session->height * session->width) * sizeof(unsigned int));

		keys = calcKey(goal, session->startX, session->startY, session->avoidWalls, session->k);
		goal->key1 = keys[0];
		goal->key2 = keys[1];
		openListAdd (session, goal);
	}
	printf("[test] pathstep 01\n");
	
	Node* currentNode;
	Node* neighborNode;
	
	int i;
	int j;
	
	unsigned int neighbor_x;
	unsigned int neighbor_y;
	int neighbor_adress;
	unsigned long distanceFromCurrent;
	
	unsigned long timeout = (unsigned long) GetTickCount();
	int loop = 0;
	
	printf("[test] pathstep 02\n");
	
	keys = calcKey(start, session->startX, session->startY, session->avoidWalls, session->k);
	start->key1 = keys[0];
	start->key2 = keys[1];
	printf("[test] pathstep 03\n");
	
    while (1) {
		// No path exists
		if (session->openListSize == 0) {
			return -1;
		}
		
        // get lowest key score member of openlist and delete it from it, shrinks openListSize
		currentNode = openListGetLowest (session);
		
		keys = calcKey(start, session->startX, session->startY, session->avoidWalls, session->k);
		start->key1 = keys[0];
		start->key2 = keys[1];
		
		keys = calcKey(currentNode, session->startX, session->startY, session->avoidWalls, session->k);
		
		printf("Before loop %d startNode   => %d %d - g: %d - rhs: %d - key1: %d - key2: %d - km: %d\n", (loop+1), start->x, start->y, start->g, start->rhs, start->key1, start->key2, session->k);
		
		printf("Before loop %d currentNode => %d %d - g: %d - rhs: %d - key1: %d - key2: %d - new-key1: %d - new-key2: %d - h: %d\n", (loop+1), currentNode->x, currentNode->y, currentNode->g, currentNode->rhs, currentNode->key1, currentNode->key2, keys[0], keys[1], heuristic_cost_estimate(currentNode->x, currentNode->y, start->x, start->y, 1));

		// Path found
		if (!((start->key1 > currentNode->key1 || (start->key1 == currentNode->key1 && start->key2 > currentNode->key2)) || start->rhs > start->g)) {
			reconstruct_path(session, goal, start);
			return 1;
		}
		
		// Timer count
		loop++;
		if (loop == 100) {
			if (GetTickCount() - timeout > session->time_max) {
				return 0;
			} else
				loop = 0;
		}
		
		if (keys[0] > currentNode->key1 || (keys[0] == currentNode->key1 && keys[1] > currentNode->key2)) {
			printf("Node key is bigger than it should be, reajusting\n");
			// Node should be lower in priority queue than it is now, downgrade it
			reajustOpenListItem(session, currentNode, keys[0], keys[1]);
			
		} else if (currentNode->g > currentNode->rhs) {
			printf("Node is overconsistent, expanding\n");
			// Node is overconsistent, expand it and remove it from piority queue
			currentNode->g = currentNode->rhs;
			openListRemove(session, currentNode);
			
			// Get all neighbors
			for (i = -1; i <= 1; i++)
			{
				for (j = -1; j <= 1; j++)
				{
					if (i == 0 && j == 0) {
						continue;
					}
					neighbor_x = currentNode->x + i;
					neighbor_y = currentNode->y + j;

					if (neighbor_x >= session->width || neighbor_y >= session->height || neighbor_x < 0 || neighbor_y < 0) {
						continue;
					}

					neighbor_adress = (neighbor_y * session->width) + neighbor_x;

					neighborNode = &session->currentMap[neighbor_adress];

					if (neighborNode->weight == 0) {
						continue;
					}

					if (i != 0 && j != 0) {
						if (session->currentMap[(currentNode->y * session->width) + neighborNode->x].weight == 0 || session->currentMap[(neighborNode->y * session->width) + currentNode->x].weight == 0) {
							continue;
						}
						distanceFromCurrent = DIAGONAL;
					} else {
						distanceFromCurrent = ORTOGONAL;
					}

					if (session->avoidWalls) {
						distanceFromCurrent += neighborNode->weight;
					}

					if (neighbor_x == session->endX && neighbor_y == session->endY) {
						continue;
					}

					// If current cell weight + distant to next cell is lower than next cell's rhs, current cell becomes the neghbor cell's new sucessor
					if (neighborNode->rhs > (currentNode->g + distanceFromCurrent)) {
						neighborNode->sucessor = currentNode->nodeAdress;
						neighborNode->rhs = currentNode->g + distanceFromCurrent;
						updateNode(session, neighborNode);
					}
				}
			}
			
			
		} else {
			printf("Node is underconsistent\n");
			// Node is underconsistent, recalculate all the rhs values and sucessors of all cells that have this Node set as their sucessor
			currentNode->g = INFINITE;
			updateNode(session, currentNode);
			
			// Get all neighbors
			for (i = -1; i <= 1; i++)
			{
				for (j = -1; j <= 1; j++)
				{
					if (i == 0 && j == 0) {
						continue;
					}
					neighbor_x = currentNode->x + i;
					neighbor_y = currentNode->y + j;

					if (neighbor_x >= session->width || neighbor_y >= session->height || neighbor_x < 0 || neighbor_y < 0) {
						continue;
					}

					neighbor_adress = (neighbor_y * session->width) + neighbor_x;

					neighborNode = &session->currentMap[neighbor_adress];

					if (neighborNode->weight == 0) {
						continue;
					}
					
					if (neighbor_x == session->endX && neighbor_y == session->endY) {
						continue;
					}
					
					// Check if neighbor's sucessor is current Node, if so get a new sucessor for the neighbot node
					if (neighborNode->sucessor == currentNode->nodeAdress) {
						get_new_neighbor_sucessor(session, neighborNode);
					}
				}
			}
		}
		printf("After loop %d currentNode => %d %d - g: %d - rhs: %d - key1: %d - key2: %d\n", loop, currentNode->x, currentNode->y, currentNode->g, currentNode->rhs, currentNode->key1, currentNode->key2);
		printf("\n");
	}
	
	printf("[test] pathstep 04\n");
}

// Get the neighbor with the least distance + weight and set it as the new sucessor
void
get_new_neighbor_sucessor (CalcPath_session *session, Node *currentNode)
{
	
	unsigned int initial_rhs = currentNode->rhs;
	
	currentNode->rhs = INFINITE;
	
	Node* neighborNode;
	
	int i;
	int j;
	
	unsigned int neighbor_x;
	unsigned int neighbor_y;
	int neighbor_adress;
	unsigned long distanceFromCurrent;
	
	// Get all neighbors
	for (i = -1; i <= 1; i++)
	{
		for (j = -1; j <= 1; j++) {
			if (i == 0 && j == 0) {
				continue;
			}
			neighbor_x = currentNode->x + i;
			neighbor_y = currentNode->y + j;
				
			if (neighbor_x >= session->width || neighbor_y >= session->height || neighbor_x < 0 || neighbor_y < 0) {
				continue;
			}
	
			neighbor_adress = (neighbor_y * session->width) + neighbor_x;

			neighborNode = &session->currentMap[neighbor_adress];

			if (neighborNode->weight == 0) {
				continue;
			}
			
			if (i != 0 && j != 0) {
				if (session->currentMap[(currentNode->y * session->width) + neighborNode->x].weight == 0 || session->currentMap[(neighborNode->y * session->width) + currentNode->x].weight == 0) {
					continue;
				}
				distanceFromCurrent = DIAGONAL;
			} else {
				distanceFromCurrent = ORTOGONAL;
			}
			
			if (session->avoidWalls) {
				distanceFromCurrent += currentNode->weight;
			}
			
			if (neighbor_x == session->endX && neighbor_y == session->endY) {
				continue;
			}
			
			// If current cell weight + distant to next cell is lower than next cell's rhs, current cell becomes the neghbor cell's new sucessor
			if (currentNode->rhs > neighborNode->g + distanceFromCurrent) {
				printf("[2] Sucessor of node %d %d changed to %d %d (g: %d | rhs: %d | key1 %d | key2: %d) from %d %d (g: %d | rhs: %d)\n", currentNode->x, currentNode->y, neighborNode->x, neighborNode->y, neighborNode->g, neighborNode->rhs, neighborNode->key1, neighborNode->key2, session->currentMap[currentNode->sucessor].x, session->currentMap[currentNode->sucessor].y, session->currentMap[currentNode->sucessor].g, session->currentMap[currentNode->sucessor].rhs);
				currentNode->rhs = neighborNode->g + distanceFromCurrent;
				currentNode->sucessor = neighbor_adress;
			}
		}
	}
	
	if (initial_rhs > currentNode->rhs) {
		printf("[ERROR] Node %d %d was used in get_new_neighbor_sucessor and its rhs value got lower. (before: %u  ||  after: %u  || weight: %lu)\n", currentNode->x, currentNode->y, initial_rhs, currentNode->rhs, currentNode->weight);
	}
	
	updateNode(session, currentNode);
}

// Create a new pathfinding session, or reset an existing session.
// Resetting is preferred over destroying and creating, because it saves
// unnecessary memory allocations, thus improving performance.
CalcPath_session *
CalcPath_init (CalcPath_session *session, unsigned char *map)
{
	unsigned int x = 0;
	unsigned int y = 0;
	
	int current;
	for (y = 0; y < session->height; y++) {
		for (x = 0; x < session->width; x++) {
			current = (y * session->width) + x;
			session->currentMap[current].x = x;
			session->currentMap[current].y = y;
			session->currentMap[current].weight = map[current];
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

// Updates a block weight
void
updateChangedMap (CalcPath_session *session, unsigned int x, unsigned int y, long delta_weight)
{
	int current = (y * session->width) + x;
	
	Node* currentNode = &session->currentMap[current];
	
	unsigned long old_weight = currentNode->weight;
	
	unsigned long new_weight = old_weight + delta_weight;
	
	printf("update map %d %d || from %lu to %lu  || delta_weight %ld\n", x, y, old_weight, new_weight, delta_weight);
	
	currentNode->weight = new_weight;
	
	//TODO: should we do this trick no never updatade cells we haven't reached yet?
	if (currentNode->rhs == INFINITE || (session->endX == currentNode->x && session->endY == currentNode->y)) {
		return;
	}
	
	//TODO: should we change rhs and g values?
	currentNode->rhs = currentNode->rhs + delta_weight;
	currentNode->g = currentNode->g + delta_weight;
	
	Node* neighborNode;
	
	int i;
	int j;
	
	unsigned int neighbor_x;
	unsigned int neighbor_y;
	int neighbor_adress;
	unsigned long distanceFromCurrent;
	
	// If cell got ligher it may have new sucessors
	if (old_weight > new_weight) {
		// Get all neighbors
		for (i = -1; i <= 1; i++)
		{
			for (j = -1; j <= 1; j++)
			{
				if (i == 0 && j == 0) {
					continue;
				}
				neighbor_x = x + i;
				neighbor_y = y + j;
					
				if (neighbor_x >= session->width || neighbor_y >= session->height || neighbor_x < 0 || neighbor_y < 0) {
					continue;
				}
	
				neighbor_adress = (neighbor_y * session->width) + neighbor_x;

				neighborNode = &session->currentMap[neighbor_adress];

				if (neighborNode->weight == 0) {
					continue;
				}
				
				if (i != 0 && j != 0) {
					if (session->currentMap[(currentNode->y * session->width) + neighborNode->x].weight == 0 || session->currentMap[(neighborNode->y * session->width) + currentNode->x].weight == 0) {
						continue;
					}
					distanceFromCurrent = DIAGONAL;
				} else {
					distanceFromCurrent = ORTOGONAL;
				}
				
				if (session->avoidWalls) {
					distanceFromCurrent += neighborNode->weight;
				}
				
				if (neighbor_x == session->endX && neighbor_y == session->endY) {
					continue;
				}
				
				// If current cell weight + distant to next cell is lower than next cell's rhs, current cell becomes the neghbor cell's new sucessor
				if (neighborNode->rhs > (currentNode->g + distanceFromCurrent)) {
					printf("[3] New sucessor of node %d %d is => node %d %d\n", neighborNode->x, neighborNode->y, currentNode->x, currentNode->y);
					neighborNode->sucessor = currentNode->nodeAdress;
					neighborNode->rhs = currentNode->g + distanceFromCurrent;
					updateNode(session, neighborNode);
				}
			}
		}
	
	// If cell got heavier it may have lost some sucessors
	} else {
		// Get all neighbors
		for (i = -1; i <= 1; i++)
		{
			for (j = -1; j <= 1; j++)
			{
				if (i == 0 && j == 0) {
					continue;
				}
				neighbor_x = x + i;
				neighbor_y = y + j;

				if (neighbor_x >= session->width || neighbor_y >= session->height || neighbor_x < 0 || neighbor_y < 0) {
					continue;
				}

				neighbor_adress = (neighbor_y * session->width) + neighbor_x;

				neighborNode = &session->currentMap[neighbor_adress];

				if (neighborNode->weight == 0) {
					continue;
				}
				
				if (i != 0 && j != 0) {
					if (session->currentMap[(currentNode->y * session->width) + neighborNode->x].weight == 0 || session->currentMap[(neighborNode->y * session->width) + currentNode->x].weight == 0) {
						continue;
					}
				}
					
				if (neighbor_x == session->endX && neighbor_y == session->endY) {
					continue;
				}
				
				// Check if neighbor's sucessor is current Node, if so get a new sucessor for the neighbot node
				if (neighborNode->sucessor == currentNode->nodeAdress) {
					get_new_neighbor_sucessor(session, neighborNode);
				}
			}
		}
	}
	
	updateNode(session, currentNode);
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
