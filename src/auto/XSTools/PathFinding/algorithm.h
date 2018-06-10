#ifndef _ALGORITHM_H_
#define _ALGORITHM_H_

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

typedef struct {
	unsigned int x;
	unsigned int y;
	unsigned int nodeAdress;
	unsigned int key1;
	unsigned int key2;
	
	bool isInOpenList;
	unsigned int openListIndex;
	
	unsigned int g;
	unsigned int rhs;
	
	unsigned int sucessor;
} Node;

typedef struct {
	bool avoidWalls;
	unsigned long time_max;
	unsigned int width;
	unsigned int height;
	unsigned int startX;
	unsigned int startY;
	unsigned int endX;
	unsigned int endY;
	int solution_size;
	int initialized;
	int run;
	int openListSize;
	unsigned int k;
	
	unsigned int *openList;
	unsigned long *map;
	Node *currentMap;
} CalcPath_session;

CalcPath_session *CalcPath_new ();

unsigned int* calcKey (Node* node, unsigned int startX, unsigned int startY, bool avoidWalls, unsigned int k);
	
int heuristic_cost_estimate (int currentX, int currentY, int startX, int startY, int avoidWalls);

void openListAdd (CalcPath_session *session, Node* node);

void openListRemove (CalcPath_session *session, Node* node);

void reajustOpenListItem (CalcPath_session *session, Node* node, unsigned int newkey1, unsigned int newkey2);

Node* openListGetLowest (CalcPath_session *session);

void updateNode (CalcPath_session *session, Node* node);

void reconstruct_path(CalcPath_session *session, Node* goal, Node* start);

int CalcPath_pathStep (CalcPath_session *session);

void get_new_neighbor_sucessor (CalcPath_session *session, Node *currentNode);
 
CalcPath_session *CalcPath_init (CalcPath_session *session);

void updateChangedMap (CalcPath_session *session, unsigned int x, unsigned int y, unsigned long new_weight);

void CalcPath_destroy (CalcPath_session *session);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* _ALGORITHM_H_ */
