#ifndef _ALGORITHM_H_
#define _ALGORITHM_H_

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

typedef struct Nodes{
	unsigned int x;
	unsigned int y;
	unsigned int nodeAdress;
	
	bool isInOpenList;
	unsigned int openListIndex;
	
	unsigned int g;
	unsigned short h;
	unsigned int rhs;
	unsigned int key[2];
	
	unsigned int predecessor;
} Node;

typedef struct {
    unsigned int x;
    unsigned int y;
    unsigned int key[2];
} TypeList;

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
	int size;
	int openListSize;
	TypeList* openList;
	const char *map;
	Node *currentMap;
} CalcPath_session;

CalcPath_session *CalcPath_new ();

void calcKey(Node* cell);

int first_key_bigger_than_second_key(unsigned int first[2], unsigned int second[2]);

int heuristic_cost_estimate(int currentX, int currentY, int goalX, int goalY, int avoidWalls);

void openListAdjustUp (CalcPath_session *session, Node* infoAdress);

void openListAdjustDown (CalcPath_session *session, Node* infoAdress);

void openListAdd (CalcPath_session *session, Node* infoAdress);

void openListRemove (CalcPath_session *session, Node* infoAdress);

void reajustOpenListItem (CalcPath_session *session, Node* infoAdress, unsigned int oldkey[2]);

Node* openListGetLowest (CalcPath_session *session);

void updateNode (CalcPath_session *session, Node* infoAdress);

int getValidNode (CalcPath_session *session, unsigned int x, unsigned int y);

int getDistanceFromCurrent (CalcPath_session *session, Node* currentNode, Node* infoAdress);

void reconstruct_path(CalcPath_session *session, Node* goal, Node* start);

int CalcPath_pathStep (CalcPath_session *session);

Node get_lowest_neighbor_rhs (CalcPath_session *session, Node currentNode);
 
CalcPath_session *CalcPath_init (CalcPath_session *session);

void CalcPath_destroy (CalcPath_session *session);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* _ALGORITHM_H_ */
