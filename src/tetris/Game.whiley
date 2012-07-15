import whiley.lang.*
import * from whiley.lang.Errors
import * from whiley.lang.System
/*
 * This File is part of the Tetris Benchmark for Whiley
 * @author LeeTrezise
 * 
 */ 
/* 
* Constants
*
*/ 
//Empty Start Grid
define startGrid as [
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null]
]
// Testing Grid. Leaves one 4*1 column clear
define testGrid as [
['R', 'R', 'R', 'R', 'R','R', 'R', 'R', 'R', null],
['R', 'R', 'R', 'R', 'R','R', 'R', 'R', 'R', null],
['R', 'R', 'R', 'R', 'R','R', 'R', 'R', 'R', null],
['R', 'R', 'R', 'R', 'R','R', 'R', 'R', 'R', null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null],
[null, null, null, null, null,null, null, null, null, null]
]


define Square as char | null
define Row as [Square]
define Grid as [Row]
define gridSq as char | null
define gridRow as [gridSq] 
define bufferGrid as [gridRow]
//
//**** BLOCKS *****
//
define BLOCK_I as {buff: [[null, 'R', null, null],[null, 'R', null, null],[null, 'R', null, null],[null, 'R', null, null]], x:19, y:5, size: 4,type: 1}
define BLOCK_J as {buff: [[null, null, null, null],['O','O', null, null],['O', 'O', null, null],[null, null, null, null]], x:19, y:5, size: 2,type: 2}
define BLOCK_L as {buff: [[null,null, 'Y', null],[null, 'Y', 'Y', null],[null, null, 'Y', null],[null, null, null, null]], x:19, y:5, size: 3,type: 3}
define BLOCK_O as {buff: [[null,null, 'G',  null],[null,'G', 'G', null],[null, 'G', null, null],[null, null, null, null]], x:19, y:5, size: 3,type: 4}
define BLOCK_S as {buff: [[null, 'B', null, null],[ null,'B', 'B', null],[null, null, 'B', null, null],[null, null, null, null]], x:19, y:5, size: 3,type: 5}
define BLOCK_T as {buff: [[null,'I', 'I', null],[null, null, 'I', null],[null, null, 'I', null],[null, null, null, null]], x:19, y:5, size: 3,type: 6}
define BLOCK_Z as {buff: [[null, null, 'V', null],[null, null, 'V', null],[null,'V', 'V', null],[null, null, null, null]], x:19, y:5, size: 3,type: 7}

public define Piece as {
	bufferGrid buff,
	int x,
	int y,
	int size,
	int type
}

public define GameState as {
	Grid rows,
	int score,
	int filled,
	int level,
	int tickTime,
	Piece current,
	Piece next
	}
	
public define Initial as {
	rows: startGrid,
	score:0,
	filled:0,
	level:1,
	tickTime:500,
	current: BLOCK_I,
	next: BLOCK_Z
}

/*
*
* Rotate the current Piece and return the updated Game State
*/
GameState ::rotate(GameState a, bool clockwise):
	//Temporary Piece buffer. Used to check colissions
	temp = [[null,null,null,null],[null,null,null,null],[null,null,null,null],[null,null,null,null]]
	if(a.current.type == 2):
		//Block is a square. No rotation, just return
		return a
	//Copy rotated cells
	i = 0
	j = 0
	while i<=3:
		j = 0
		while j <= 3:
			if(clockwise):
				//Rotate Clockwise
				temp[3-j][i] = a.current.buff[i][j]
			else:
				temp[j][3-i] = a.current.buff[i][j]
			j = j+1
		i = i+1
	tempCurrent = a.current
	tempCurrent.buff = temp
	//Temporary Piece to Check Post-Rotation collision
	tempGS =  { rows: a.rows, score:a.score, filled: a.filled, level:a.level, current: tempCurrent, tickTime:a.tickTime, next: a.next} 
	if(checkCollision(0,0,tempGS)):
		//Collision Happened. Do not rotate
		return a
	else:
		//No Collision Detected. Free to Rotate
		return tempGS

/*
* Generate a new Piece randomly. Random Function could be improved
* Uses Java - Random.nextInt(int)	
*
*/
Piece ::generate():
	b = Random.getRandomInt(7)
	a = BLOCK_L
	if b == 0:
		a = BLOCK_I
	else if b == 1:
		a = BLOCK_J 
	else if b == 2:
		a = BLOCK_L
	else if b == 3:
		a = BLOCK_O
	else if b == 4:
		a = BLOCK_S
	else if b == 5:
		a = BLOCK_T
	else:
		a = BLOCK_Z
	a.x = 19
	a.y = 4
	return a

/*
*
* Delete all full rows. Returns the updated Gamestate
*
*/	
GameState ::deleteRows(GameState a):
	filledRows = 0 //Number of rows filled
	i = 0
	j = 0
	while i <= 18:
		j = 0
		hasfullRow = true
		while j < 10:
			if(a.rows[i][j] == null):
				hasfullRow = false
			j= j+1
		if hasfullRow:
			//Row is full. Need to move everything down
			//If the row is full, we need to recheck it again after move
			//So no increment to i.
			cx = -1
			cy = j
			while cx<=8:
				cx = cx+1
				cy = i
				while cy <= 18:
					a.rows[cy][cx] = a.rows[cy+1][cx]
					cy = cy + 1						 		
			filledRows = filledRows + 1
		else:
			//If we dont get a full row, move up.
			i = i+1
	a.filled = a.filled + filledRows
	//Update Score here too.
	x = 0
	if filledRows == 1:
		x = (a.level*40) + 40
	else if filledRows == 2:
		x = (a.level*100) + 100
	else if filledRows == 3:
		x = (a.level*300) + 300
	else if filledRows == 4:
		x = (a.level*1200) + 1200
	a.score = a.score+x
	//Update Level
	if(a.filled >= a.level*10):
		//Update The Level here.
		a.level = a.level+1	
		//Change the Ticktime. 
		a.tickTime = a.tickTime-30
	return a

/*
* Hard Drop the current Piece. 
*/				
GameState ::hardDrop(GameState a):
	while(!checkCollision(-1,0,movePiece(a, -1, 0))):
		a = movePiece(a, -1, 0)
	a = movePiece(a, -1, 0)
	return a

/*
* Moves the Current Piece. Also Responsible for Updating the rows
* and generating the new Piece. 
*/

GameState ::movePiece(GameState a, int x, int y):
	if(checkCollision(0, y, a)):
		//Piece moves laterally.
		abc = 1+1
		//Collides laterally. Ignore
	else:
		a.current.y = a.current.y+y
	if(checkCollision(x,0,a)):
		if(x < 0):
			if(a.current.x >= 18):
				iterate = false
			else:
				ai = 0
				aj = 0
				while ai <= 3:
					aj = 0
					while aj <= 3:
						if(a.current.buff[ai][aj] != null):
							a.rows[a.current.x+ai][a.current.y+aj] = a.current.buff[ai][aj]
						aj= aj+1
					ai = ai+1
				//If we get here. The Block collides. Assign a new one
				a.current = a.next
				a.next = generate()
				//Check For Filled Rows
				a = deleteRows(a)
				
	else:
	//If we get here, the block just moves.
		a.current.x = a.current.x+x
	return a
/*
* Check to see if the movement will cause a collision.
*/
bool checkCollision(int dx, int dy,GameState a):
	newx = a.current.x + dx
	newy = a.current.y + dy
	// Check For Collisions
	i = 0
	j = 1
	while i <=3:
		while j<=3:
			if  a.current.buff[i][j] != null:// TODO
				//Check Inside the Borders
				if(newy+j < 0 || newy + j >= 10 || newx+i >= 22 || newx + i <0):
					return true
				if a.rows[newx+i][newy+j] != null:
					return true
			j = j+1
		i=i+1
		j = 0
	return false

string getUIString(GameState a):
	str = ""
	i = 0
	while i <= 3:
		j = 0
		while j <= 3:
			if a.current.buff[i][j] != null:
				a.rows[a.current.x+i][a.current.y+j] = a.current.buff[i][j]
			j=j+1
		i = i + 1
	i = 0
	j = 0
	while i<10:
		j = 0
		while j<=20:
			if(a.rows[j][i] == null):
				str = str + 'X'
			else:
				str = str + a.rows[j][i]
			j = j+1
		i = i+1
	
	return str