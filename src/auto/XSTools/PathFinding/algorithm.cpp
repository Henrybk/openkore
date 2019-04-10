#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <algorithm>
#include <stdexcept>
#include <vector>
#include <stack>

#include "algorithm.h"

#define DIAGONAL 14
#define ORTOGONAL 10

#define NONE 0
#define OPEN 1
#define CLOSED 2

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

void _Freenode(rp_heap* heap, _Node* _Node_Pointer)
{
	_Node_Pointer->trueNode_pointer = nullptr;
    _Node_Pointer->_Left_Node = nullptr;
    _Node_Pointer->_Next_Node = nullptr;
    _Node_Pointer->_Parent_Node = nullptr;
    _Node_Pointer->_Rank = 0;
	heap->_Mysize--;
}

void _Insert_root(rp_heap* heap, _Node* _Node_Pointer)
{
	if (heap->_Myhead == nullptr)
	{
		//printf("Inserted in Myhead.\n");
		heap->_Myhead = _Node_Pointer;
		_Node_Pointer->_Next_Node = _Node_Pointer;
	}
	else
	{
		//printf("Inserted in the normal heap.\n");
		_Node_Pointer->_Next_Node = heap->_Myhead->_Next_Node;
		heap->_Myhead->_Next_Node = _Node_Pointer;
		if (compare_node(_Node_Pointer->trueNode_pointer, heap->_Myhead->trueNode_pointer))
			heap->_Myhead = _Node_Pointer;
	}
}

_Node* _Link(_Node* _Left, _Node* _Right)
{
	if (_Right == nullptr) {
		return _Left;
	}

	_Node* _Winner;
	_Node* _Loser;
	if (compare_node(_Right->trueNode_pointer, _Left->trueNode_pointer))
	{
		_Winner = _Right;
		_Loser = _Left;
	}
	else
	{
		_Winner = _Left;
		_Loser = _Right;
	}
	_Loser->_Parent_Node = _Winner;
	if (_Winner->_Left_Node)
	{
		_Loser->_Next_Node = _Winner->_Left_Node;
		_Loser->_Next_Node->_Parent_Node = _Loser;
	}
	_Winner->_Left_Node = _Loser;
	_Winner->_Rank = _Loser->_Rank + 1;
	return _Winner;
}

bool compare_node(AstarNode* left, AstarNode* right)
{
	return left->f < right->f;
}

bool heap_empty(rp_heap* heap)
{
	return heap->_Mysize == 0;
}

unsigned long heap_size(rp_heap* heap)
{
	return heap->_Mysize;
}

AstarNode* heap_top(rp_heap* heap)
{
	return heap->_Myhead->trueNode_pointer;
}

_Node* heap_push(rp_heap* heap, AstarNode* trueNode)
{
	_Node* _Node_Pointer = &heap->_NodeList[trueNode->nodeAdress];
	_Node_Pointer->trueNode_pointer = trueNode;
	_Node_Pointer->_Left_Node = nullptr;
    _Node_Pointer->_Next_Node = nullptr;
    _Node_Pointer->_Parent_Node = nullptr;
    _Node_Pointer->_Rank = 0;
	_Insert_root(heap, _Node_Pointer);
	heap->_Mysize++;
	return _Node_Pointer;
}

unsigned long _Max_bucket_size(rp_heap* heap) //ceil(log2(size)) + 1
{
	unsigned long _Bit = 1, _Count = heap->_Mysize;
	while (_Count >>= 1)
		_Bit++;
	return _Bit + 1;
}

AstarNode* heap_pop(rp_heap* heap)
{
	if (heap_empty(heap)) {
		throw std::runtime_error("pop error: empty heap");
	}
		AstarNode* trueNode_pointer = heap->_Myhead->trueNode_pointer;
		//printf("Myhead is node %d %d.\n", trueNode_pointer->x, trueNode_pointer->y);
		unsigned long bucket_size = _Max_bucket_size(heap);
		std::vector<_Node*> _Bucket((bucket_size*2), nullptr);
		//_Node* NodeArray = (_Node*) calloc (bucket_size, sizeof(_Node));
	for (_Node* _Node_Pointer = heap->_Myhead->_Left_Node; _Node_Pointer;)
	{
		_Node* _NextPtr = _Node_Pointer->_Next_Node;
		_Node_Pointer->_Next_Node = nullptr;
		_Node_Pointer->_Parent_Node = nullptr;
		//_Multipass(_Bucket, _Node_Pointer);
		while (_Bucket[_Node_Pointer->_Rank] != nullptr)
		{
			unsigned int _Rank = _Node_Pointer->_Rank;
			_Node_Pointer = _Link(_Node_Pointer, _Bucket[_Rank]);
			_Bucket[_Rank] = nullptr;
		}
		_Bucket[_Node_Pointer->_Rank] = _Node_Pointer;
		_Node_Pointer = _NextPtr;
	}
	for (_Node* _Node_Pointer = heap->_Myhead->_Next_Node; _Node_Pointer != heap->_Myhead; )
	{
		_Node* _NextPtr = _Node_Pointer->_Next_Node;
		_Node_Pointer->_Next_Node = nullptr;
		//_Multipass(_Bucket, _Node_Pointer);
		while (_Bucket[_Node_Pointer->_Rank] != nullptr)
		{
			unsigned int _Rank = _Node_Pointer->_Rank;
			_Node_Pointer = _Link(_Node_Pointer, _Bucket[_Rank]);
			_Bucket[_Rank] = nullptr;
		}
		_Bucket[_Node_Pointer->_Rank] = _Node_Pointer;
		_Node_Pointer = _NextPtr;
	}
	_Freenode(heap, heap->_Myhead);
	heap->_Myhead = nullptr;
	std::for_each(_Bucket.begin(), _Bucket.end(), [&](_Node* _Node_Pointer)
	{
		if (_Node_Pointer)
			_Insert_root(heap, _Node_Pointer);
	});
	//printf("Myhead 2 is node %d %d.\n", trueNode_pointer->x, trueNode_pointer->y);
	return trueNode_pointer;
}

void heap_clear(rp_heap* heap)
{
	if (!heap_empty(heap))
	{
		std::stack<_Node*> _Stack_in, _Stack_out;
		_Stack_in.push(heap->_Myhead);
		while (!_Stack_in.empty())
		{
			_Node* _Node_Pointer = _Stack_in.top();
			_Stack_in.pop();
			_Stack_out.push(_Node_Pointer);
			if (_Node_Pointer->_Left_Node)
				_Stack_in.push(_Node_Pointer->_Left_Node);
			if (_Node_Pointer->_Next_Node && _Node_Pointer->_Next_Node != heap->_Myhead)
				_Stack_in.push(_Node_Pointer->_Next_Node);
		}
		while (!_Stack_out.empty())
		{
			_Node* _Node_Pointer = _Stack_out.top();
			_Freenode(heap, _Node_Pointer);
			_Stack_out.pop();
		}
	}
	heap->_Myhead = nullptr;
}

void heap_decrease(rp_heap* heap, AstarNode* trueNode)
{
	_Node* _Node_Pointer = &heap->_NodeList[trueNode->nodeAdress];
	//?if (compare_node(trueNode, _Node_Pointer->trueNode_pointer))
	//?	_Node_Pointer->trueNode_pointer = trueNode;
	if (_Node_Pointer == heap->_Myhead)
		return;
	if (_Node_Pointer->_Parent_Node == nullptr) //one of the roots
	{
		if (compare_node(_Node_Pointer->trueNode_pointer, heap->_Myhead->trueNode_pointer))
			heap->_Myhead = _Node_Pointer;
	}
	else
	{
		_Node* _ParentPtr = _Node_Pointer->_Parent_Node;
		if (_Node_Pointer == _ParentPtr->_Left_Node)
		{
			_ParentPtr->_Left_Node = _Node_Pointer->_Next_Node;
			if (_ParentPtr->_Left_Node)
				_ParentPtr->_Left_Node->_Parent_Node = _ParentPtr;
		}
		else
		{
			_ParentPtr->_Next_Node = _Node_Pointer->_Next_Node;
			if (_ParentPtr->_Next_Node)
				_ParentPtr->_Next_Node->_Parent_Node = _ParentPtr;
		}
		_Node_Pointer->_Next_Node = _Node_Pointer->_Parent_Node = nullptr;
		_Node_Pointer->_Rank = (_Node_Pointer->_Left_Node) ? _Node_Pointer->_Left_Node->_Rank + 1 : 0;
		_Insert_root(heap, _Node_Pointer);
		if (_ParentPtr->_Parent_Node == nullptr) // is a root
			_ParentPtr->_Rank = (_ParentPtr->_Left_Node) ? _ParentPtr->_Left_Node->_Rank + 1 : 0;
		else
		{
			while (_ParentPtr->_Parent_Node)
			{
				int i = _ParentPtr->_Left_Node ? _ParentPtr->_Left_Node->_Rank : -1;
				int j = _ParentPtr->_Next_Node ? _ParentPtr->_Next_Node->_Rank : -1;
#ifdef TYPE1_RANK_REDUCTION
				int k = (i != j) ? std::max(i, j) : i + 1; //type-1 rank reduction
#else
				int k = (abs(i - j) > 1) ? std::max(i, j) : std::max(i, j) + 1; //type-2 rank reduction
#endif // TYPE1_RANK_REDUCTION
				if (k >= _ParentPtr->_Rank)
					break;
				_ParentPtr->_Rank = k;
				_ParentPtr = _ParentPtr->_Parent_Node;
			}
		}
	}
}

int
heuristic_cost_estimate (int currentX, int currentY, int goalX, int goalY, int avoidWalls)
{
	int xDistance = abs(currentX - goalX);
	int yDistance = abs(currentY - goalY);

	int hScore = (ORTOGONAL * (xDistance + yDistance)) + ((DIAGONAL - (2 * ORTOGONAL)) * ((xDistance > yDistance) ? yDistance : xDistance));

	//if (avoidWalls) {
	//	hScore += (((xDistance > yDistance) ? xDistance : yDistance) * 10);
	//}

	return hScore;
}

void
reconstruct_path(CalcPath_session *session, AstarNode* goal, AstarNode* start)
{
	AstarNode* currentNode = goal;

	session->solution_size = 0;
	while (currentNode->nodeAdress != start->nodeAdress)
	{
		currentNode = &session->currentMap[currentNode->predecessor];
		session->solution_size++;
	}
}

int
CalcPath_pathStep (CalcPath_session *session)
{
	if (!session->initialized) {
		return -2;
	}

	AstarNode* start = &session->currentMap[((session->startY * session->width) + session->startX)];
	AstarNode* goal = &session->currentMap[((session->endY * session->width) + session->endX)];

	if (!session->run) {
		session->run = 1;

		heap_push(session->heap, start);
		start->whichlist = OPEN;
	}

	AstarNode* currentNode;
	AstarNode* neighborNode;

	int i;
	int j;

	int neighbor_x;
	int neighbor_y;
	unsigned long neighbor_adress;
	unsigned long distanceFromCurrent;

	unsigned int g_score = 0;

	unsigned long timeout = (unsigned long) GetTickCount();
	int loop = 0;
	int loop2 = 0;

	while (1) {
		// No path exists
		if (heap_empty(session->heap)) {
			return -1;
		}

		loop++;
		loop2++;
		if (loop == 100) {
			if (GetTickCount() - timeout > session->time_max) {
				return 0;
			} else
				loop = 0;
		}

		//printf("Before pop - loop is %d - size is %lu.\n", loop2, heap_size(session->heap));
		currentNode = heap_pop(session->heap);
		//printf("Popped node is %d %d.\n", currentNode->x, currentNode->y);
		currentNode->whichlist = CLOSED;
        //printf("Top of heap is %d %d.\n", currentNode->x, currentNode->y);

		//if current is the goal, return the path.
		if (currentNode->nodeAdress == goal->nodeAdress) {
			//return path
			reconstruct_path(session, goal, start);
			return 1;
		}

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

				if (session->map_base_weight[neighbor_adress] == -1) {
					continue;
				}

				neighborNode = &session->currentMap[neighbor_adress];

				if (neighborNode->whichlist == CLOSED) {
					continue;
				}

				if (i != 0 && j != 0) {
				   if (session->map_base_weight[(currentNode->y * session->width) + neighbor_x] == -1 || session->map_base_weight[(neighbor_y * session->width) + currentNode->x] == -1) {
						continue;
					}
					distanceFromCurrent = DIAGONAL;
				} else {
					distanceFromCurrent = ORTOGONAL;
				}
				if (session->avoidWalls) {
					distanceFromCurrent += session->map_base_weight[neighbor_adress];
				}

				g_score = currentNode->g + distanceFromCurrent;

				if (neighborNode->whichlist == NONE) {
					neighborNode->x = neighbor_x;
					neighborNode->y = neighbor_y;
					neighborNode->nodeAdress = neighbor_adress;
					neighborNode->predecessor = currentNode->nodeAdress;
					neighborNode->g = g_score;
					neighborNode->h = heuristic_cost_estimate(neighborNode->x, neighborNode->y, session->endX, session->endY, session->avoidWalls);
					neighborNode->f = neighborNode->g + neighborNode->h;

					//printf("Before push %d %d - weight %d.\n", neighborNode->x, neighborNode->y, session->map_base_weight[neighbor_adress]);
					heap_push(session->heap, neighborNode);
					neighborNode->whichlist = OPEN;
				} else {
					if (g_score < neighborNode->g) {
						neighborNode->predecessor = currentNode->nodeAdress;
						neighborNode->g = g_score;
						neighborNode->f = neighborNode->g + neighborNode->h;
						heap_decrease(session->heap, neighborNode);
					}
				}
			}
		}
	}
	return -1;
}

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

// Create a new pathfinding session, or reset an existing session.
// Resetting is preferred over destroying and creating, because it saves
// unnecessary memory allocations, thus improving performance.
void
CalcPath_init (CalcPath_session *session)
{
	/* Allocate enough memory in currentMap to hold all cells in the map */
	session->currentMap = (AstarNode*) calloc(session->height * session->width, sizeof(AstarNode));

    session->heap = (rp_heap*) malloc (sizeof (rp_heap));
    session->heap->_NodeList = (_Node*) calloc (session->height * session->width, sizeof(_Node));
	session->heap->_Myhead = nullptr;
    session->heap->_Mysize = 0;

	unsigned long goalAdress = (session->endY * session->width) + session->endX;
	AstarNode* goal = &session->currentMap[goalAdress];
	goal->x = session->endX;
	goal->y = session->endY;
	goal->nodeAdress = goalAdress;

	unsigned long startAdress = (session->startY * session->width) + session->startX;
	AstarNode* start = &session->currentMap[startAdress];
	start->x = session->startX;
	start->y = session->startY;
	start->nodeAdress = startAdress;
	start->h = heuristic_cost_estimate(start->x, start->y, goal->x, goal->y, session->avoidWalls);
	start->f = start->h;

	session->initialized = 1;
}

void
free_currentMap (CalcPath_session *session)
{
	free(session->currentMap);
}

void
free_openList (CalcPath_session *session)
{
	free(session->heap->_NodeList);
	free(session->heap);
}

void
CalcPath_destroy (CalcPath_session *session)
{
	if (session->initialized) {
		free(session->currentMap);
	}

	if (session->run) {
		free(session->heap->_NodeList);
		free(session->heap);
	}

	free(session);
}
