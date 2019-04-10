#ifndef _ALGORITHM_H_
#define _ALGORITHM_H_

typedef struct {
	int x;
	int y;

	unsigned long nodeAdress;

	unsigned int predecessor;

	unsigned int whichlist;

	unsigned long g;
	unsigned long h;
	unsigned long f;
} AstarNode;

typedef struct _Node _Node;

struct _Node {
    AstarNode* trueNode_pointer;
    _Node* _Left_Node;
    _Node* _Next_Node;
    _Node* _Parent_Node;
    int _Rank;
};

typedef struct {
    _Node* _Myhead;
	_Node* _NodeList;
    unsigned long _Mysize;
} rp_heap;

typedef struct {
	bool avoidWalls;

	unsigned long time_max;

	int width;
	int height;

	int startX;
	int startY;
	int endX;
	int endY;

	int solution_size;
	int initialized;
	int run;

	int size;

	char *map_base_weight;
	AstarNode *currentMap;

	rp_heap *heap;

} CalcPath_session;


void _Freenode(rp_heap* heap, _Node* _Node_Pointer);

void _Insert_root(rp_heap* heap, _Node* _Node_Pointer);

_Node* _Link(_Node* _Left, _Node* _Right);

bool compare_node(AstarNode* left, AstarNode* right);

bool heap_empty(rp_heap* heap);

unsigned long heap_size(rp_heap* heap);

AstarNode* heap_top(rp_heap* heap);

_Node* heap_push(rp_heap* heap, AstarNode* trueNode);

unsigned long _Max_bucket_size(rp_heap* heap);

AstarNode* heap_pop(rp_heap* heap);

void heap_clear(rp_heap* heap);

void heap_decrease(rp_heap* heap, AstarNode* trueNode);

CalcPath_session *CalcPath_new ();

bool compare_node(AstarNode* left, AstarNode* right);

int heuristic_cost_estimate(int currentX, int currentY, int goalX, int goalY, int avoidWalls);

void reconstruct_path(CalcPath_session *session, AstarNode* goal, AstarNode* start);

int CalcPath_pathStep (CalcPath_session *session);

void CalcPath_init (CalcPath_session *session);

void free_currentMap (CalcPath_session *session);

void free_openList (CalcPath_session *session);

void CalcPath_destroy (CalcPath_session *session);

#endif /* _ALGORITHM_H_ */
