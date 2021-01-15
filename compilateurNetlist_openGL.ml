(*  par décret impérial,
    0->11 : sortie (secondes unités upto années dizaines)
    12 : is_second_even
    15 : tick d'horloge
    14 : date
    15 : secondes depuis le début de la journée
*)

let filename = ref ""

let verbose = ref false




let decl () = 
"#ifdef __APPLE__
/* Defined before OpenGL and GLUT includes to avoid deprecation messages */
#define GL_SILENCE_DEPRECATION
#include <GLUT/glut.h>
#else
#include <GL/glut.h>
#endif
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define TRUE 1
#define FALSE 0

#define YELLOW 0.90625,0.76171875,0.2265625
#define VIOLET_LIGHT 0.34375,0.15234375,0.44921875 
#define VIOLET_DARK 0.296875,0.1015625,0.40625

char *mmio;


char *second1, *second10, *minute1, *minute10, *hour1, *hour10, *year1, *year10, *month1, *month10, *day1, *day10;

char *is_second_even;
char *draw;

long tps;
long tps_tmp;

int numberSteps=-1;
int iStep;
int iFrame=0;
unsigned long long addr;
char liste[256];

char hyperspeed=0;
char speed_analysis=0;

int segListIndex;

int win;

void reset_view(){
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(-4.375, 5.200, -5.0, 2.0);
    //glOrtho(-100,100,-100,100,-100,100);
    glMatrixMode(GL_MODELVIEW);
}


void light_segment(){
    glColor3f(YELLOW);
}

void dim_segment(){
    glColor3f(VIOLET_DARK);
}


void color_segment(char *code, int seg_num){
    *(code+seg_num-1) ? light_segment() : dim_segment();
}


void seven_segment(char *code, float left, float top, float right, float bot){
    /* code: 7 bits, each bit code for one segment
     * ¯¯¯1¯¯¯
     * |    |
     * 4    6
     * |    |
     * ---2---
     * |    |
     * 5    7
     * |    |
     * ___3___
     */
    /* computing the coordinates */
    float height = (top-bot)/2; /* scale y */
    float width = (right-left); /* scale x */
    float mid_y = bot + height;
    
    glLoadIdentity();
    glTranslatef(left,bot,0.0);
    glScalef(width, height, 1.0);
    
    color_segment(code, 3);   glCallList(segListIndex);
    color_segment(code, 5);   glCallList(segListIndex+1);
    color_segment(code, 7);   glTranslatef(1,0.0, 0.0);   glCallList(segListIndex+1);
    color_segment(code, 6);   glTranslatef(0.0, 1.0, 0.0); glCallList(segListIndex+1);
    color_segment(code, 4);   glTranslatef(-1.0, 0.0, 0.0); glCallList(segListIndex+1);
    color_segment(code, 2);   glCallList(segListIndex);
    color_segment(code, 1);   glTranslatef(0.0, 1.0, 0.0); glCallList(segListIndex);
}

void second_dots(int is_on, float left, float top, float right, float bot){
    float height = (top-bot)/2;
    float width = (right-left);
    if(is_on){
        light_segment();
    }
    else{
        dim_segment();
    }
    glLoadIdentity();
    glTranslatef(left+(width/2),bot+(height/2),0.0);
    glScalef(width, width, 1.0);
    glCallList(segListIndex+2);
    glTranslatef(0.0, height/width, 0.0);
    glCallList(segListIndex+2);
    reset_view();
}


void render_string(char string[], float x, float y){
    
    light_segment();
    glLoadIdentity();
    glTranslatef(x,y,0.);
    glScalef(1/152.38, 1/152.38, 1/152.38);
    glScalef(0.25, 0.25, 1.0);
    glPushMatrix();
    for(int i=0; i<strlen(string); i=i+1){
        glutStrokeCharacter(GLUT_STROKE_MONO_ROMAN,string[i]);
    }
    glPopMatrix();
}

void kbd_react(unsigned char key, int mouse_x, int mouse_y){
    if(key=='Q'){
    glutDestroyWindow(win);
    exit(0);
    }
}
"

let debut () = ref
"void init(){
    /* define the horizontal segment primitive */
    segListIndex = glGenLists(3);
    if (segListIndex != 0){
        glNewList(segListIndex,GL_COMPILE);
            glBegin(GL_POLYGON);
                glVertex2f(0.02,      0.0);
                glVertex2f(0.125,     0.125);
                glVertex2f(0.875,     0.125);
                glVertex2f(0.98,      0.0);
                glVertex2f(0.875,     -0.125);
                glVertex2f(0.125,     -0.125);
            glEnd();
        glEndList();
        /* define the vertical segment primitive */
        glNewList(segListIndex+1, GL_COMPILE);
            glBegin(GL_POLYGON);
                glVertex2f(0.0,     0.02);
                glVertex2f(-0.105,  0.135);
                glVertex2f(-0.105,  0.855);
                glVertex2f(0.0,     0.98);
                glVertex2f(0.105,   0.855);
                glVertex2f(0.105,   0.135);
            glEnd();
        glEndList();
        glNewList(segListIndex+2, GL_COMPILE);
            GLUquadricObj* qobj = gluNewQuadric();
            glBegin(GL_POLYGON);
                gluDisk(qobj, 0.0, 1.0, 50, 1);
            glEnd();
            gluDeleteQuadric(qobj);
        glEndList();
    }
    glLineWidth(3.0);
    
    
    //mmio = malloc(144);
"


let debutBoucle i = 
(* la RAM est déjà définie, on peut donc déjà faire le MMIO *)
"
\tmmio= o + "^string_of_int i^";
\tsecond1 = mmio + 0;
\tsecond10 = mmio + 7;
\tminute1 = mmio + 14;
\tminute10 = mmio + 21;
\thour1 = mmio + 33;
\thour10 = mmio + 41;
\tday1 = mmio + 49;
\tday10 = mmio + 57;
\tmonth1 = mmio + 65;
\tmonth10 = mmio+ 73;
\tyear1 = mmio + 81;
\tyear10 = mmio + 89;

\tis_second_even = mmio+31;
\tdraw = mmio + 30;

    tps = (long) time(NULL);

    for(int j=0; j<32; j=j+1){
        mmio[128+ 31-j] = 1 & (tps >> j);
    }
    int i=0;
}

void displ(){
    *draw = 0;
    iFrame = iFrame + 1;
    glClearColor(VIOLET_LIGHT, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);
    reset_view();
    // hours 10s
    seven_segment(hour10, -3.3, 1.0, -2.3, -1.0);
    // hours 1s
    seven_segment(hour1, -2.0, 1.0, -1.0, -1.0);
    // hours text
    render_string(\"HOUR\", -2.5, -1.5);
    // minute separator
    second_dots(*is_second_even, -0.6, 1.0, -0.4 , -1.0);
    
    // minute 10s
    seven_segment(minute10, 0.0, 1.0, 1.0, -1.0);
    // minute 1s
    seven_segment(minute1, 1.3, 1.0, 2.3, -1.0);
    // minute text
    render_string(\"MINUTE\", 0.6, -1.5);
    
    // seconds 10s
    seven_segment(second10, 3.0, -0.075, 3.5, -1.075);
    // seconds 1s
    seven_segment(second1, 3.7, -0.075, 4.2, -1.075);
    // second text
    render_string(\"SECOND\", 3.1, -1.5);
    
    
    // days 10S
    seven_segment(day10, -3.0, -2.6, -2.3, -4.0);
    // days 1s
    seven_segment(day1, -2.0, -2.6, -1.3, -4.0);
    // days text
    render_string(\"DAY\", -2.4, -4.5);
    
    
    // months 10s
    seven_segment(month10, -0.45, -2.6, 0.25, -4.0);
    // months 1s
    seven_segment(month1, 0.55, -2.6, 1.25, -4.0);
    // months text
    render_string(\"MONTH\", 0, -4.5);
    
    // year 10s
    seven_segment(year10, 2.1, -2.6, 2.8, -4.0);
    // year 1s
    seven_segment(year1, 3.1, -2.6, 3.8, -4.0);
    // year text
    render_string(\"YEAR\", 2.6, -4.5);
    
    //glTranslatef(-115.0, 0.0, 0.0);
    //glScalef(0.3, 0.3, 1.0);

    glFlush();
    
}

void update() {

    tps = (long) time(NULL);
    
    if(hyperspeed){
        *is_second_even = 1 ^ *is_second_even;
    } else {
    *is_second_even = tps & 1;
    }
    if(speed_analysis){
        printf(\"Frame: %d \t Cycle: %d \\r\", iFrame, iStep);
    }
    if(numberSteps > -1 & iStep >=numberSteps){
        glutDestroyWindow(win);
        printf(\"\\n\");
        exit(0);
    }
    else{
"

let finBoucle () = (* RAM : array named o *)
"
    iStep = iStep+1;
    if(*draw){glutPostRedisplay();}
}
"

let fin () =
"
int main(int argc, char *argv[]){
    // get CLI arguments
    for(int i=1; i<argc;i=i+1){
        if(strcmp(argv[i],\"-n\")==0){
            if(i<argc-1){
                numberSteps = atoi(argv[i+1]);
                if((numberSteps == 0) & (strcmp(argv[i+1],\"0\"))){
                    printf(\"Invalid number of steps indicated. Please reconsider.\\n\");
                    return(1);
                }
                i = i+1;
            } else {
                printf(\"Please indicate a valid step count\\n\");
                return(1);
            }
        } else if(strcmp(argv[i],\"-hs\") == 0){
            hyperspeed = 1;
        } else if(strcmp(argv[i],\"-sa\") == 0){
            speed_analysis = 1;
        } else {
            printf(\"Please give valid arguments.\\nArguments:  -n : number of cycles (mandatory); -hs : enable hyperspeed; -sa : speed analysis \\n\");
            return(1);
        }
        }
    
    
    //int argc = 1;
    //char *argv[1]={(char*)\"NULL\"};
    
    glutInit(&argc,argv);
    glutInitDisplayMode(GLUT_RGB|GLUT_SINGLE);
    glutInitWindowSize(300,300);
    win = glutCreateWindow(\"Clock, or is it glock ?\");
    glutKeyboardFunc(kbd_react);
    init();
    glutIdleFunc(update);
    glutDisplayFunc(displ);
    glutMainLoop();
}
"

let get_filename s = filename := s

let main () =
  Arg.parse 
  	[("-v", Arg.Set verbose, "Prints more debug information");("-size", Arg.Set_int CompilateurNetlist.max_size, "Address size of ram allowed (by default 10)")]
    get_filename "";
    
    CompilateurNetlist.compile (decl ()) (debut ()) (debutBoucle (32 lsl !CompilateurNetlist.max_size)) (finBoucle ()) (fin ()) !filename !verbose
;;
main ()
