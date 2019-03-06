#ifndef _ALGORITHM_H_
#define _ALGORITHM_H_

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

typedef struct {
	unsigned int x;
	unsigned int y;
	long weight;
	
	unsigned long nodeAdress;
	
	unsigned long key1;
	unsigned long key2;
	
	bool isInOpenList;
	long openListIndex;
	
	unsigned long g;
	unsigned long rhs;
	
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
	
	long openListSize;
	
	unsigned int k;
	
	unsigned long *openList;
	Node *currentMap;
} CalcPath_session;

CalcPath_session *CalcPath_new ();

unsigned long* calcKey (Node* node, unsigned int startX, unsigned int startY, bool avoidWalls, unsigned int k);
	
int heuristic_cost_estimate (int currentX, int currentY, int startX, int startY, int avoidWalls);

void openListAdd (CalcPath_session *session, Node* node);

void openListRemove (CalcPath_session *session, Node* node);

void reajustOpenListItem (CalcPath_session *session, Node* node, unsigned long newkey1, unsigned long newkey2);

void updateNode (CalcPath_session *session, Node* node);

void reconstruct_path(CalcPath_session *session, Node* goal, Node* start);

int CalcPath_pathStep (CalcPath_session *session);

void get_new_neighbor_sucessor (CalcPath_session *session, Node *currentNode);
 
CalcPath_session *CalcPath_init (CalcPath_session *session, unsigned char *map);

int updateChangedMap (CalcPath_session *session, unsigned int x, unsigned int y, long delta_weight);

void free_currentMap (CalcPath_session *session);

void free_openList (CalcPath_session *session);

void CalcPath_destroy (CalcPath_session *session);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* _ALGORITHM_H_ */
