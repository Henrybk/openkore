#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include "algorithm.h"

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

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

unsigned long*
calcKey (Node* node, int startX, int startY, bool avoidWalls, unsigned int k)
{
	static unsigned long key[2];
	
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
	
	int hScore = (10 * (xDistance + yDistance)) - (6 * ((xDistance > yDistance) ? yDistance : xDistance));
	
	return hScore;
}

// Openlist is a binary heap of min-heap type
// Each member in openList is the adress (nodeAdress) of a node in the map (session->currentMap)

// Add node 'currentNode' to openList
void 
openListAdd (CalcPath_session *session, Node* currentNode)
{
	// Index will be 1 + last index in openList, which is also its size
	// Save in currentNode its index in openList
	currentNode->openListIndex = session->openListSize;
	currentNode->isInOpenList = 1;
	
	// Defines openList[index] to currentNode adress
	session->openList[currentNode->openListIndex] = currentNode->nodeAdress;
	
	// Increses openListSize by 1, since we just added a new member
	session->openListSize++;
	
	long parentIndex = (long)floor((currentNode->openListIndex - 1) / 2);
	Node* parentNode;
	
	// Repeat while currentNode still has a parent node, otherwise currentNode is the top node in the heap
	while (parentIndex >= 0) {
		
		parentNode = &session->currentMap[session->openList[parentIndex]];
		
		// If parent node is bigger than currentNode, exchange their positions
		if (parentNode->key1 > currentNode->key1 || (parentNode->key1 == currentNode->key1 && parentNode->key2 > currentNode->key2)) {
			// Changes the node adress of openList[currentNode->openListIndex] (which is 'currentNode') to that of openList[parentIndex] (which is the current parent of 'currentNode')
			session->openList[currentNode->openListIndex] = session->openList[parentIndex];
			
			// Changes openListIndex of the current parent of 'currentNode' to that of 'currentNode' since they exchanged positions
			parentNode->openListIndex = currentNode->openListIndex;
			
			// Changes the node adress of openList[parentIndex] (which is the current parent of 'currentNode') to that of openList[currentNode->openListIndex] (which is 'currentNode')
			session->openList[parentIndex] = currentNode->nodeAdress;
			
			// Changes openListIndex of 'currentNode' to that of the current parent of 'currentNode' since they exchanged positions
			currentNode->openListIndex = parentIndex;
			
			// Updates parentIndex to that of the current parent of 'currentNode'
			parentIndex = (long)floor((currentNode->openListIndex - 1) / 2);
			
		} else {
			break;
		}
	}
}

// Remove node 'currentNode' from openList
void 
openListRemove (CalcPath_session *session, Node* currentNode)
{
	
	// Decreases openList size
	session->openListSize--;
	
	// Cannot move last node to this node place if this node is the last in openList
	if (currentNode->openListIndex == session->openListSize) {
		currentNode->isInOpenList = 0;
		currentNode->openListIndex = 0;
		
	} else {
	
		// Since it was decreaased, but the node was not removed yet, session->openListSize is now also the index of the last node in openList
		// We move the last node in openList to this position and adjust it down as necessary
		session->openList[currentNode->openListIndex] = session->openList[session->openListSize];
		
		Node* movedNode;
		
		// TODO
		movedNode = &session->currentMap[session->openList[currentNode->openListIndex]];
		
		// TODO
		movedNode->openListIndex = currentNode->openListIndex;
		
		// Saves in currentNode that it is no longer in openList
		currentNode->isInOpenList = 0;
		currentNode->openListIndex = 0;
		
		long parentIndex = (long)floor((movedNode->openListIndex - 1) / 2);
		
		// Sometimes we may need to move it up (look http://www.mathcs.emory.edu/~cheung/Courses/171/Syllabus/9-BinTree/heap-delete.html)
		if (parentIndex >= 0 && (session->currentMap[session->openList[parentIndex]].key1 > movedNode->key1 || (session->currentMap[session->openList[parentIndex]].key1 == movedNode->key1 && session->currentMap[session->openList[parentIndex]].key2 > movedNode->key2))) {
				
			Node* parentNode;
			while (parentIndex >= 0) {
				parentNode = &session->currentMap[session->openList[parentIndex]];
				
				if (parentNode->key1 > movedNode->key1 || (parentNode->key1 == movedNode->key1 && parentNode->key2 > movedNode->key2)) {
					session->openList[movedNode->openListIndex] = session->openList[parentIndex];
					
					parentNode->openListIndex = movedNode->openListIndex;
					
					session->openList[parentIndex] = movedNode->nodeAdress;
					
					movedNode->openListIndex = parentIndex;
					
					parentIndex = (long)floor((movedNode->openListIndex - 1) / 2);
					
				} else {
					break;
				}
			}
		
		// But almost always it will need to be moved down
		} else {
			long smallerChildIndex;
			Node* smallerChildNode;
			
			long rightChildIndex = 2 * movedNode->openListIndex + 2;
			Node* rightChildNode;
			
			long leftChildIndex = 2 * movedNode->openListIndex + 1;
			Node* leftChildNode;
			
			long lastIndex = session->openListSize-1;
			
			while (leftChildIndex <= lastIndex) {

				//There are 2 children
				if (rightChildIndex <= lastIndex) {
					
					rightChildNode = &session->currentMap[session->openList[rightChildIndex]];
					leftChildNode = &session->currentMap[session->openList[leftChildIndex]];
					
					if (rightChildNode->key1 > leftChildNode->key1 || (rightChildNode->key1 == leftChildNode->key1 && rightChildNode->key2 > leftChildNode->key2)) {
						smallerChildIndex = leftChildIndex;
					} else {
						smallerChildIndex = rightChildIndex;
					}
				
				//There is 1 children
				} else {
					smallerChildIndex = leftChildIndex;
				}
				
				smallerChildNode = &session->currentMap[session->openList[smallerChildIndex]];
				
				if (movedNode->key1 > smallerChildNode->key1 || (movedNode->key1 == smallerChildNode->key1 && movedNode->key2 > smallerChildNode->key2)) {
					
					// Changes the node adress of openList[movedNode->openListIndex] (which is 'movedNode') to that of openList[smallerChildIndex] (which is the current child of 'movedNode')
					session->openList[movedNode->openListIndex] = smallerChildNode->nodeAdress;
					
					// Changes openListIndex of the current child of 'movedNode' to that of 'movedNode' since they exchanged positions
					smallerChildNode->openListIndex = movedNode->openListIndex;
					
					// Changes the node adress of openList[smallerChildIndex] (which is the current child of 'movedNode') to that of openList[movedNode->openListIndex] (which is 'movedNode')
					session->openList[smallerChildIndex] = movedNode->nodeAdress;
					
					// Changes openListIndex of 'movedNode' to that of the current child of 'movedNode' since they exchanged positions
					movedNode->openListIndex = smallerChildIndex;
					
					// Updates rightChildIndex and leftChildIndex to those of the current children of 'movedNode'
					rightChildIndex = 2 * movedNode->openListIndex + 2;
					leftChildIndex = 2 * movedNode->openListIndex + 1;
					
				} else {
					break;
				}
			}
		}
	}
}

// Reajusts node 'currentNode' location in openList
void 
reajustOpenListItem (CalcPath_session *session, Node* currentNode, unsigned long newkey1, unsigned long newkey2)
{
	// Node got ligher, so we ajust it up
	if (currentNode->key1 > newkey1 || (currentNode->key1 == newkey1 && currentNode->key2 > newkey2)) {
		// Dont really know abut the 2 next lines ( TODO )
		currentNode->key1 = newkey1;
		currentNode->key2 = newkey2;
		
		long parentIndex = (long)floor((currentNode->openListIndex - 1) / 2);
		Node* parentNode;
		
		while (parentIndex >= 0) {
			parentNode = &session->currentMap[session->openList[parentIndex]];
			
			if (parentNode->key1 > currentNode->key1 || (parentNode->key1 == currentNode->key1 && parentNode->key2 > currentNode->key2)) {
				session->openList[currentNode->openListIndex] = session->openList[parentIndex];
				
				parentNode->openListIndex = currentNode->openListIndex;
				
				session->openList[parentIndex] = currentNode->nodeAdress;
				
				currentNode->openListIndex = parentIndex;
				
				parentIndex = (long)floor((currentNode->openListIndex - 1) / 2);
				
			} else {
				break;
			}
		}
	
	// Node got heavier, so we ajust it down
	} else {
		// Dont really know abut the 2 next lines ( TODO )
		currentNode->key1 = newkey1;
		currentNode->key2 = newkey2;
	
		long smallerChildIndex;
		Node* smallerChildNode;
		
		long rightChildIndex = 2 * currentNode->openListIndex + 2;
		Node* rightChildNode;
		
		long leftChildIndex = 2 * currentNode->openListIndex + 1;
		Node* leftChildNode;
		
		long lastIndex = session->openListSize-1;
		
		while (leftChildIndex <= lastIndex) {

			//There are 2 children
			if (rightChildIndex <= lastIndex) {
				
				rightChildNode = &session->currentMap[session->openList[rightChildIndex]];
				leftChildNode = &session->currentMap[session->openList[leftChildIndex]];
				
				if (rightChildNode->key1 > leftChildNode->key1 || (rightChildNode->key1 == leftChildNode->key1 && rightChildNode->key2 > leftChildNode->key2)) {
					smallerChildIndex = leftChildIndex;
				} else {
					smallerChildIndex = rightChildIndex;
				}
			
			//There is 1 children
			} else {
				smallerChildIndex = leftChildIndex;
			}
			
			smallerChildNode = &session->currentMap[session->openList[smallerChildIndex]];
			
			if (currentNode->key1 > smallerChildNode->key1 || (currentNode->key1 == smallerChildNode->key1 && currentNode->key2 > smallerChildNode->key2)) {
				
				// Changes the node adress of openList[currentNode->openListIndex] (which is 'currentNode') to that of openList[smallerChildIndex] (which is the current child of 'currentNode')
				session->openList[currentNode->openListIndex] = smallerChildNode->nodeAdress;
				
				// Changes openListIndex of the current child of 'currentNode' to that of 'currentNode' since they exchanged positions
				smallerChildNode->openListIndex = currentNode->openListIndex;
				
				// Changes the node adress of openList[smallerChildIndex] (which is the current child of 'currentNode') to that of openList[currentNode->openListIndex] (which is 'currentNode')
				session->openList[smallerChildIndex] = currentNode->nodeAdress;
				
				// Changes openListIndex of 'currentNode' to that of the current child of 'currentNode' since they exchanged positions
				currentNode->openListIndex = smallerChildIndex;
				
				// Updates rightChildIndex and leftChildIndex to those of the current children of 'currentNode'
				rightChildIndex = 2 * currentNode->openListIndex + 2;
				leftChildIndex = 2 * currentNode->openListIndex + 1;
				
			} else {
				break;
			}
		}
	}
}

void 
updateNode (CalcPath_session *session, Node* currentNode)
{
	if (currentNode->g != currentNode->rhs) {
		if (currentNode->isInOpenList) {
			unsigned long* keys = calcKey(currentNode, session->startX, session->startY, session->avoidWalls, session->k);
			reajustOpenListItem(session, currentNode, keys[0], keys[1]);
		} else {
			unsigned long* keys = calcKey(currentNode, session->startX, session->startY, session->avoidWalls, session->k);
			currentNode->key1 = keys[0];
			currentNode->key2 = keys[1];
			openListAdd (session, currentNode);
		}
		
	} else if (currentNode->isInOpenList) {
		openListRemove(session, currentNode);
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
	if (!session->initialized) {
		return -2;
	}
	
	Node* start = &session->currentMap[((session->startY * session->width) + session->startX)];
	Node* goal = &session->currentMap[((session->endY * session->width) + session->endX)];
	
	unsigned long* keys;
	
	if (!session->run) {
		session->run = 1;
		session->openListSize = 0;
		session->openList = (unsigned long*) malloc((session->height * session->width) * sizeof(unsigned long));

		keys = calcKey(goal, session->startX, session->startY, session->avoidWalls, session->k);
		
		goal->key1 = keys[0];
		goal->key2 = keys[1];
		openListAdd (session, goal);
	}
	
	Node* currentNode;
	Node* neighborNode;
	
	short i;
 	short i_x[8] = {0, 0, 1, -1, 1, 1, -1, -1};
	short i_y[8] = {1, -1, 0, 0, 1, -1, -1, 1};
	
	int neighbor_x;
	int neighbor_y;
	unsigned long neighbor_adress;
	unsigned long distanceFromCurrent;
	
	unsigned long timeout = (unsigned long) GetTickCount();
	int loop = 0;
	
	keys = calcKey(start, session->startX, session->startY, session->avoidWalls, session->k);
	start->key1 = keys[0];
	start->key2 = keys[1];
	
	
	while (1) {
		// No path exists
		if (session->openListSize == 0) {
			return -1;
		}
		
		// get lowest key score member of openlist and delete it from it, shrinks openListSize
		currentNode = &session->currentMap[session->openList[0]];
		
		start->key2 = ((start->g > start->rhs) ? start->rhs : start->g);
		start->key1 = start->key2 + session->k;
		
		keys = calcKey(currentNode, session->startX, session->startY, session->avoidWalls, session->k);

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
			// Node should be lower in priority queue than it is now, downgrade it
			reajustOpenListItem(session, currentNode, keys[0], keys[1]);
			
		} else if (currentNode->g > currentNode->rhs) {
			// Node is overconsistent, expand it and remove it from piority queue
			currentNode->g = currentNode->rhs;
			openListRemove(session, currentNode);
			
			// Get all neighbors
			for (i = 0; i <= 7; i++)
			{
				neighbor_x = currentNode->x + i_x[i];
				neighbor_y = currentNode->y + i_y[i];

				if (neighbor_x >= session->width || neighbor_y >= session->height || neighbor_x < 0 || neighbor_y < 0) {
					continue;
				}

				neighbor_adress = (neighbor_y * session->width) + neighbor_x;

				if (session->map_base_weight[neighbor_adress] == -1) {
					continue;
				}

				neighborNode = &session->currentMap[neighbor_adress];
			
				if (neighborNode->initialized == 0) {
					initializeNode(session, neighbor_x, neighbor_y);
				}

				if (i >= 4) {
					if (session->map_base_weight[(currentNode->y * session->width) + neighborNode->x] == -1 || session->map_base_weight[(neighborNode->y * session->width) + currentNode->x] == -1) {
						continue;
					}
					distanceFromCurrent = 14;
				} else {
					distanceFromCurrent = 10;
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
			
			
		} else {
			// Node is underconsistent, recalculate all the rhs values and sucessors of all cells that have this Node set as their sucessor
			currentNode->g = 10000000;
			updateNode(session, currentNode);
			
			// Get all neighbors
			for (i = 0; i <= 7; i++)
			{
				neighbor_x = currentNode->x + i_x[i];
				neighbor_y = currentNode->y + i_y[i];

				if (neighbor_x >= session->width || neighbor_y >= session->height || neighbor_x < 0 || neighbor_y < 0) {
					continue;
				}

				neighbor_adress = (neighbor_y * session->width) + neighbor_x;

				if (session->map_base_weight[neighbor_adress] == -1) {
					continue;
				}

				neighborNode = &session->currentMap[neighbor_adress];
			
				if (neighborNode->initialized == 0) {
					initializeNode(session, neighbor_x, neighbor_y);
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
}

// Get the neighbor with the least distance + weight and set it as the new sucessor
void
get_new_neighbor_sucessor (CalcPath_session *session, Node *currentNode)
{
	currentNode->rhs = 10000000;
	
	Node* neighborNode;
	
	short i;
 	short i_x[8] = {0, 0, 1, -1, 1, 1, -1, -1};
	short i_y[8] = {1, -1, 0, 0, 1, -1, -1, 1};
	
	int neighbor_x;
	int neighbor_y;
	unsigned long neighbor_adress;
	unsigned long distanceFromCurrent;
	
	
	// Get all neighbors
	for (i = 0; i <= 7; i++)
	{
		neighbor_x = currentNode->x + i_x[i];
		neighbor_y = currentNode->y + i_y[i];
		
		if (neighbor_x >= session->width || neighbor_y >= session->height || neighbor_x < 0 || neighbor_y < 0) {
			continue;
		}
	
		neighbor_adress = (neighbor_y * session->width) + neighbor_x;

		if (session->map_base_weight[neighbor_adress] == -1) {
			continue;
		}

		neighborNode = &session->currentMap[neighbor_adress];
		
		if (neighborNode->initialized == 0) {
			initializeNode(session, neighbor_x, neighbor_y);
		}
		
		if (i >= 4) {
			if (session->map_base_weight[(currentNode->y * session->width) + neighborNode->x] == -1 || session->map_base_weight[(neighborNode->y * session->width) + currentNode->x] == -1) {
				continue;
			}
			distanceFromCurrent = 14;
		} else {
			distanceFromCurrent = 10;
		}
		
		if (session->avoidWalls) {
			distanceFromCurrent += currentNode->weight;
		}
		
		if (neighbor_x == session->endX && neighbor_y == session->endY) {
			continue;
		}
		
		// If current cell weight + distant to next cell is lower than next cell's rhs, current cell becomes the neghbor cell's new sucessor
		if (currentNode->rhs > neighborNode->g + distanceFromCurrent) {
			currentNode->rhs = neighborNode->g + distanceFromCurrent;
			currentNode->sucessor = neighbor_adress;
		}
	}
	
	updateNode(session, currentNode);
}

// Create a new pathfinding session, or reset an existing session.
// Resetting is preferred over destroying and creating, because it saves
// unnecessary memory allocations, thus improving performance.
void
CalcPath_init (CalcPath_session *session)
{
	/* Allocate enough memory in currentMap to hold all cells in the map */
	session->currentMap = (Node*) calloc(session->height * session->width, sizeof(Node));
	
	initializeNode(session, session->endX, session->endY);
	
	Node* goal = &session->currentMap[((session->endY * session->width) + session->endX)];
	goal->rhs = 0;
	
	initializeNode(session, session->startX, session->startY);
	
	session->k = 0;
	session->initialized = 1;
}

void
initializeNode (CalcPath_session *session, int x, int y)
{
	unsigned long current;

	current = ((y * session->width) + x);
	
	Node* currentNode = &session->currentMap[current];
	
	currentNode->x = x;
	currentNode->y = y;
	currentNode->nodeAdress = current;
	currentNode->g = 10000000;
	currentNode->rhs = 10000000;
	currentNode->weight = session->map_base_weight[current];
	currentNode->initialized = 1;
}

// Updates a block weight
int
updateChangedMap (CalcPath_session *session, int x, int y, long delta_weight)
{
	unsigned long current = (y * session->width) + x;
	
	Node* currentNode = &session->currentMap[current];
	
	if (currentNode->initialized == 0) {
		initializeNode(session, x, y);
	}
	
	long old_weight = currentNode->weight;
	
	long new_weight = old_weight + delta_weight;
	
	if (new_weight <= 0) {
		printf("[Pathfinding error] Map node set to have negative weight on updateChangedMap (%d %d || from %ld to %ld || delta_weight %ld).\n", x, y, old_weight, new_weight, delta_weight);
		return 0;
	}
	
	currentNode->weight = new_weight;
	
	//TODO: should we do this trick no never updatade cells we haven't reached yet?
	if (currentNode->rhs == 10000000 || (session->endX == currentNode->x && session->endY == currentNode->y)) {
		return 1;
	}
	
	//TODO: should we change rhs and g values?
	currentNode->rhs = currentNode->rhs + delta_weight;
	currentNode->g = currentNode->g + delta_weight;
	
	Node* neighborNode;
	
	short i;
 	short i_x[8] = {0, 0, 1, -1, 1, 1, -1, -1};
	short i_y[8] = {1, -1, 0, 0, 1, -1, -1, 1};
	
	int neighbor_x;
	int neighbor_y;
	unsigned long neighbor_adress;
	unsigned long distanceFromCurrent;
	
	// If cell got ligher it may have new sucessors
	if (old_weight > new_weight) {
		// Get all neighbors
		for (i = 0; i <= 7; i++)
		{
			neighbor_x = x + i_x[i];
			neighbor_y = y + i_y[i];
			
			if (neighbor_x >= session->width || neighbor_y >= session->height || neighbor_x < 0 || neighbor_y < 0) {
				continue;
			}
	
			neighbor_adress = (neighbor_y * session->width) + neighbor_x;

			if (session->map_base_weight[neighbor_adress] == -1) {
				continue;
			}

			neighborNode = &session->currentMap[neighbor_adress];
			
			if (neighborNode->initialized == 0) {
				initializeNode(session, neighbor_x, neighbor_y);
			}
			
			if (i >= 4) {
				if (session->map_base_weight[(currentNode->y * session->width) + neighborNode->x] == -1 || session->map_base_weight[(neighborNode->y * session->width) + currentNode->x] == -1) {
					continue;
				}
				distanceFromCurrent = 14;
			} else {
				distanceFromCurrent = 10;
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
	
	// If cell got heavier it may have lost some sucessors
	} else {
		// Get all neighbors
		for (i = 0; i <= 7; i++)
		{
			neighbor_x = x + i_x[i];
			neighbor_y = y + i_y[i];

			if (neighbor_x >= session->width || neighbor_y >= session->height || neighbor_x < 0 || neighbor_y < 0) {
				continue;
			}

			neighbor_adress = (neighbor_y * session->width) + neighbor_x;

			if (session->map_base_weight[neighbor_adress] == -1) {
				continue;
			}

			neighborNode = &session->currentMap[neighbor_adress];
			
			if (neighborNode->initialized == 0) {
				initializeNode(session, neighbor_x, neighbor_y);
			}
			
			if (i >= 4) {
				if (session->map_base_weight[(currentNode->y * session->width) + neighborNode->x] == -1 || session->map_base_weight[(neighborNode->y * session->width) + currentNode->x] == -1) {
					continue;
				}
			}
				
			if (neighbor_x == session->endX && neighbor_y == session->endY) {
				continue;
			}
			
			// Check if neighbor's sucessor is current Node, if so get a new sucessor for the neighbor node
			if (neighborNode->sucessor == currentNode->nodeAdress) {
				get_new_neighbor_sucessor(session, neighborNode);
			}
		}
	}
	
	updateNode(session, currentNode);
	return 1;
}

void
free_currentMap (CalcPath_session *session)
{
	free(session->currentMap);
}

void
free_openList (CalcPath_session *session)
{
	free(session->openList);
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
	free(session);
}

#ifdef __cplusplus
}
#endif /* __cplusplus */
