#Processing comunicate with Ardduino

/*
  Name: Inversione di marcia di un m.a.t.(motore asincrono trifase) tramite relè pilotati da Arduino
  Copyright: Moreno Laci. All rights reserved
  Author: Moreno Laci
  Date: 20/12/15 16.31
  Description: Questo programma ci consente di comunicare, via seriale, con arduino. Lo scopo del programma è di gestire tre relè che apriranno e chiuderanno
               dei contatti che eccitano o diseccitano due contattori, o più comunemente teleruttori. Questi teleruttori hanno il compito di azionare in un 
               senso o nell'altro il motore.
               L'interfaccia è cosi composta:
                  - tre luci, una rossa, una verde, un'altra rossa. La prima, da destra, di luce indica la marcia indietro, la seconda che il motore è fermo
                    e la terza la marcia avanti del motore;
                  - quattro pulsanti: indietro, stop, avanti e automatico. Il primo serve ad azionare il comando di marcia indietro e funziona solo se il motore
                    non è in funzione. Il secondo serve per disinserire il motore e funzionara in indifferentemente dello stato del motore. Il terzo serve per 
                    azionare la marcia avanti del motore. L'ultimo pulsante azionerà un ciclo di lavorazione, avanti-stop-indietro-stop e così via, scandido da
                    intervalli che saranno elencati nel programma. L'ultimo bottone è stato ideato per ipotizzare una lavorazione di fabbrica automatizzata.
*/
import cc.arduino.*;
import processing.serial.*;

Arduino arduino;  


final int Indietro = 10;  //i pin di arduino
final int Stop = 11;
final int Avanti = 12;


//-------------------------------------------BOTTONI----------------------------------------------------------------------------------------

int IndX = 100, StopX = IndX + 200, AvX = StopX + 200, AutoX = AvX + 200;                                 //Ascissa( la x) di tutti i bottoni
int BtnY = 400, BtnW = 150, BtnH = 100;                                                                   //Imposto gli elementi comuni a tutti i bottoni
String avanti = "AVANTI", indietro = "INDIETRO", stop = "STOP", automatico = "AUTO";                      //imposto le didascalie dei bottoni
color IndCl = color(255,0,0), StopCl = color(0,255,0), AvCl = color(255,0,0), AutoCl = color(255,255,0);  //imposto i colori dei bottoni
int IndCont = 1, StopCont = 1, AvCont = 1, AutoCont = 1;                                                  //setto lo spessore dei contorni dei bottoni
boolean click;                                                                           //ci dirà se stiamo premendo il mouse (true) o meno(false). Serve per l'attivazione dei relè
boolean Auto = false;                                                                            //se è true non posso attivare l'avanti e l'indietro solo stop
//------------------------------------------LUCI-------------------------------------------------------------------------------------------

int LedIndX = 250, LedStopX = LedIndX + 200, LedAvX = LedStopX + 200;                                     //L'ascissa delle luci
int LedY = 150, LedRag = 100;                                                                             //gli elementi comuni
color LedIndCl , LedStopCl , LedAvCl ;                                                                    //creo le variabili dei colori delle tre luci
boolean IndVer = false, StopVer = false, AvVer = false;                                                    //se true luce accesa, se false spenta. Ci danno in oltre informazione sullo
                                                                                                           //stato del motore
//=================================================SETUP================================================================================================

void setup()
{
  size(900,600);
  background(0,155,155);
  println(Serial.list());
  arduino = new Arduino(this, "COM9", 57600);
  
  arduino.pinMode(Indietro, Arduino.OUTPUT);      //settiamo i pin
  arduino.pinMode(Stop, Arduino.OUTPUT);
  arduino.pinMode(Avanti, Arduino.OUTPUT);
  
  arduino.digitalWrite(Avanti, Arduino.HIGH);     //spengo i relè avanti indietro
  arduino.digitalWrite(Indietro, Arduino.HIGH);
  
  arduino.digitalWrite(Stop, Arduino.LOW);        //attivo lo stop, per fermare da subito il circuito AC
  delay(200);
  arduino.digitalWrite(Stop, Arduino.HIGH);       //disattivo lo stop
  
  StopVer = true;                                 //il motore è spento inizialmente
}

//====================================================DRAW=========================================================================================
 
void draw()
{ 
  frameRate(60);
  PFont carBtn = loadFont("SansSerif.plain-25.vlw");  //Inizializiamo il font e la grandezza di tutti i testi che useremo
  
  
  //---------Indietro--------------------------------------------------------------------------------------------------
  if(presenza(IndX, BtnY, BtnW, BtnH) == true) {     //se il mouse è sopra il bottone ingrosso il contorno del pulsante
    
    IndCont = 7;       //imposto lo spessore del contorno
    
    if(mousePressed == true && Auto == false && AvVer == false) {      //se un pulsante del mouse è premuto e non siamo in modalità automatica cambiamo il colore
      IndCl = color(80,0,0);
      click = true;
      drawButton(IndX, BtnY, BtnW, BtnH, carBtn, indietro, IndCl, IndCont);
      Attivazione(click, Indietro);   //attivo il relè
      
      if(IndVer == AvVer) {  //il motore non può cambiare direzione senza essere fermato
        IndVer = true;     //impostiamo lo stato elle luci
        StopVer = false;
        AvVer = false;
       
      }
    }
    
    else {
     click = false;
     IndCl = color(255,0,0);
     drawButton(IndX, BtnY, BtnW, BtnH, carBtn, indietro, IndCl, IndCont);
     Attivazione(click, Indietro);           //diseccito il relè
    }
  }
  
  else{                        //se il mouse no è sopra lasciamo il bottone in defaut
    IndCont = 1;
    IndCl = color(255,0,0);
    drawButton(IndX, BtnY, BtnW, BtnH, carBtn, indietro, IndCl, IndCont);
    
    click = false;
    Attivazione(click, Indietro);            //diseccito il relè
  }
  
  //---------Stop--------------------------------------------------------------------------------------------------------
  
  Stop();    //Chiamato funzione stop. Non ha argomenti perchè usa solo funzioni globali e una locale
  
  //---------Avanti-------------------------------------------------------------------------------------------------------
  if(presenza(AvX, BtnY, BtnW, BtnH) == true) { //uguale a sopra
    AvCont = 7;
    
    if(mousePressed == true && Auto == false && IndVer == false) {
      AvCl = color(80,0,0);
      click = true;
      drawButton(AvX, BtnY, BtnW, BtnH, carBtn, avanti, AvCl, AvCont);
      Attivazione(click, Avanti);
      
      if(AvVer == IndVer) {    //il motore non può cambiare direzione senza prima essere stato fermato
        IndVer = false;     //impostiamo lo stato elle luci
        StopVer = false;
        AvVer = true;
        
      }
      
    }
    
    else {
      click  = false;
      AvCl = color(255,0,0);
      drawButton(AvX, BtnY, BtnW, BtnH, carBtn, avanti, AvCl, AvCont);
      Attivazione(click, Avanti);
    }
    
  }
  
  else {
    AvCont = 1;
    AvCl = color(255,0,0);
    drawButton(AvX, BtnY, BtnW, BtnH, carBtn, avanti, AvCl, AvCont);
    click  = false;
    Attivazione(click, Avanti);
  }
  
  //---------Automatico---------------------------------------------------------------------------------------------------
  if(presenza(AutoX, BtnY, BtnW, BtnH) == true) {  //uguale a sopra
    AutoCont = 7;
    
    if(mousePressed == true && AvVer == false && IndVer == false) {
      AutoCl = color(80,80,0);
      drawButton(AutoX, BtnY, BtnW, BtnH, carBtn, automatico, AutoCl, AutoCont);
      
      Auto = true;      //setto gli stati del sistema tutti falsi e l'auto vero
      IndVer = false;     
      StopVer = false;
      AvVer = false;
      
      thread("Automatico");    //modalità automatica, usando un processo separato al draw
    }
    
    else {
      AutoCl = color(255,255,0);
      drawButton(AutoX, BtnY, BtnW, BtnH, carBtn, automatico, AutoCl, AutoCont);
    }
  }
  
  else {
    AutoCont = 1;
    AutoCl = color(255,255,0);
    drawButton(AutoX, BtnY, BtnW, BtnH, carBtn, automatico, AutoCl, AutoCont); 
  }
    
  
  //---------Luce di segnalazione marcia indietro---------------------------------------------------------------------------
  
  if(IndVer == true ) {
    LedIndCl = color(255,0,0);
    drawLight(LedIndX, LedY, LedRag, LedIndCl, indietro);
  }
  
  else{
    LedIndCl = color(80,0,0);
    drawLight(LedIndX, LedY, LedRag, LedIndCl, indietro);
  }
  
  //---------Luce di segnalazione di stop-----------------------------------------------------------------------------------
  if(StopVer == true) {
    LedStopCl = color(0,255,0);
    drawLight(LedStopX, LedY, LedRag, LedStopCl, stop);
  }
  
  else{
    LedStopCl = color(0,80,0);
    drawLight(LedStopX, LedY, LedRag, LedStopCl, stop);
  }
  
  //---------Luce di segnalazione marcia avanti----------------------------------------------------------------------------
  if(AvVer == true ) {
    LedAvCl = color(255,0,0);
    drawLight(LedAvX, LedY, LedRag, LedAvCl, avanti);
  }
  
  else {
    LedAvCl = color(80,0,0);
    drawLight(LedAvX, LedY, LedRag, LedAvCl, avanti);
  }
 
  
}

//=========================================DEFINIAMO LE FUNZIONI=====================================================================================================

//----------------------------------------PARTE GRAFICA------------------------------------------------------------------------------------------------------
 void drawButton(int x, int y, int w, int h,PFont car, String nome, color c, int strk) {  //Useremo questa funzione per disegnare tutti i nostri pulsanti
  stroke(0);
  strokeWeight(strk);
  fill(c);
  rect(x, y, w, h);       //disegno il pulsante 
  
  textFont(car);
  fill(0);
  text(nome, x + 20, y + 60);       //Scrivo  nel pulsante 
    
 }
 
 void drawLight(int x, int y, int r, color c ,String nome) {  //Per disegnare le lucine dei cerchi colorati 
    PFont carLed = loadFont("SansSerif.plain-15.vlw");  //font da mettere sopra i led
 
    stroke(155);
    strokeWeight(6);
    fill(c);
    ellipse(x,y,r,r);  //essendo un ellisse deve avere uguali lrghezze 
   
    textFont(carLed);
    fill(0);
    text(nome, x-20, y-60);  //scrivo sopra la lucina
 }
 
 //----------------------------------------PARTE DI CONTROLLO------------------------------------------------------------------------------------------------------
 
 void Stop() {                                  //funzione per il controllo della pressione del pulsante di stop oppure del passsagio sopra di essi
   
   PFont font = loadFont("SansSerif.plain-25.vlw");
   
   if(presenza(StopX, BtnY, BtnW, BtnH) == true) {
    StopCont = 7;
    
    if(mousePressed == true) {
       StopCl = color(0,80,0);
       click = true;
       drawButton(StopX, BtnY, BtnW, BtnH, font, stop, StopCl, StopCont);
       Attivazione(click, Stop);
       
      IndVer = false;     //impostiamo lo stato elle luci
      StopVer = true;
      AvVer = false;
      
      Auto = false; //fermiamo la modalità automatica se è in corso
    }
    else {
      click = false;
      StopCl = color(0,255,0);
      drawButton(StopX, BtnY, BtnW, BtnH, font, stop, StopCl, StopCont);
      Attivazione(click, Stop);  
    }
  }
  
  else {                             //se nessuna condizione è verificata riportiamo il pulsante alla condizione di default
     StopCont = 1;
     StopCl = color(0,255,0);
     drawButton(StopX, BtnY, BtnW, BtnH, font, stop, StopCl, StopCont);
     
     click = false;
     Attivazione(click, Stop);  
  }
 }
 //------------------------------------------------------------------------------------------------------------------------------------------------------------
  boolean presenza(int x, int y, int w, int h) {  //controlliamo se il mouse è sopra un pulsante
  boolean verifica ;
  
  if((mouseX > x && mouseX < x + w) && (mouseY > y && mouseY < y+h)) {  //La freccia deve stare all'interno del rettangolo
    verifica = true;
  }
  else { 
    verifica = false;
  }
   
    return verifica;
 }
 //---------------------------------------------------------------------------------------------------------------------------------------------------------------
 void Attivazione(boolean ok, int pin) { //per attivare i relè
    
   if(ok == true) { 
    arduino.digitalWrite(pin, Arduino.LOW);  //I relè si attivano se gli si dà 0V e non 5V
   }
   else {
    arduino.digitalWrite(pin, Arduino.HIGH); 
   }
   
 }
 
 //==================================================================WORK IN PROGRES=====================================================================
void Automatico() {
      int delayMove = 10000;  //I tempi dei vari delay
      int delayStop = 3000;
      int delayAvvio = 1000;
      
      for(;;) {       //inizia il ciclo di lavorazione TOTALE, di tuti i pezzi
            
        for(int k=1; k<=4; k++) {      //inizia il ciclo di lavorazione PARZIALE, di un pezzo
            if(Auto == false) break;   //se lo stop è stato premuto si esce condizione che ci srà parecchie volte
            
            if(k==2 || k==4 ) {
              arduino.digitalWrite(Stop, Arduino.LOW);
              StopVer = true;                            //imposto lo stato delle luce, e del sistema
              AvVer = false;
              IndVer = false;
            }
            
            else if(k==1) {
              arduino.digitalWrite(Avanti, Arduino.LOW);
              StopVer = false;
              AvVer = true;
              IndVer = false;
            }
            
            else if(k==3) {
              arduino.digitalWrite(Indietro, Arduino.LOW);
              StopVer = false;
              AvVer = false;
              IndVer = true;
            }
            
            if(Auto == true) delay(delayAvvio);  
            
            if(k==2 || k==4) {                                   //Rilascio lo stop e il motore sta fermo per 3 secondi
              arduino.digitalWrite(Stop, Arduino.HIGH);
              if(Auto == false) break;                     //se il pulsante stop viene premuto esco dal ciclo
              delay(delayStop);
            }
            else if(k==1) {                                      //Rilascio l'avanti e il motore va avanti per 10 secondi
               arduino.digitalWrite(Avanti, Arduino.HIGH);
               if(Auto == false) break;
               delay(delayMove);
            }
            else if(k==3) {                                      //Rilascio l'indietro e il motore va indietro per 10 secondi
               arduino.digitalWrite(Indietro, Arduino.HIGH);
               if(Auto == false) break;
               delay(delayMove);
            }
            
          } 
          
         if(Auto == false) break;
      }
}   
