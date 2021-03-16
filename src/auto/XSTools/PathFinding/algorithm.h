#ifndef _ALGORITHM_H_
#define _ALGORITHM_H_

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

typedef struct {
	bool initialized;
	
	int x;
	int y;
	long weight;
	
	bool isInOpenList;
	
	long openListIndex;
	
	unsigned long key1;
	unsigned long key2;
	unsigned long g;
	unsigned long rhs;
	
	unsigned long nodeAdress;
	unsigned long sucessor;
} Node;

typedef struct {
	bool avoidWalls;
	
	unsigned long time_max;
	
	int width;
	int height;
	
	int min_x;
	int max_x;
	int min_y;
	int max_y;
	
	int startX;
	int startY;
	int endX;
	int endY;
	
	int initialized;
	int run;
	
	unsigned long k;
	
	long openListSize;
	
	long solution_size;
	
	const char *map_base_weight;
	Node *currentMap;
	
	unsigned long *openList;
} CalcPath_session;

CalcPath_session *CalcPath_new ();

// Actual pathing algorithm
void CalcPath_init (CalcPath_session *session);

int CalcPath_pathStep (CalcPath_session *session);

void reconstruct_path(CalcPath_session *session, Node* goal, Node* start);

// Node management
void initializeNode (CalcPath_session *session, int x, int y);

unsigned long* calcKey (Node* node, int startX, int startY, unsigned int k);

unsigned long heuristic_cost_estimate (int currentX, int currentY, int startX, int startY);

// openList management
void updateNode (CalcPath_session *session, Node* node);

void openListAdd (CalcPath_session *session, Node* node);

void openListRemove (CalcPath_session *session, Node* node);

void openListReajust (CalcPath_session *session, Node* node, unsigned long newkey1, unsigned long newkey2);

// Related to D* Lite map updating
int updateChangedMap (CalcPath_session *session, int x, int y, long delta_weight);

void get_new_neighbor_sucessor (CalcPath_session *session, Node *currentNode);

// Memory cleaning
void free_currentMap (CalcPath_session *session);

void free_openList (CalcPath_session *session);

void CalcPath_destroy (CalcPath_session *session);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* _ALGORITHM_H_ */