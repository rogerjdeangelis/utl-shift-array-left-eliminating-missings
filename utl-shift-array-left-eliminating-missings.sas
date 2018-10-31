Shift array left eliminating missings                                                                                
                                                                                                                     
Good question                                                                                                        
                                                                                                                     
This is a nice example of using 'proc transpose' to remove missings and shift                                        
elements of an array left.                                                                                           
Also shows the power of normalization.                                                                               
                                                                                                                     
I had trouble understanding the rules, maybe this is what you were asing for,                                        
If not you should be able to edit the havFix datastep.                                                               
                                                                                                                     
https://communities.sas.com/t5/SAS Data Management/adding data/m p/508296                                            
                                                                                                                     
It may be possible to do all the processing in the merge but                                                         
th code will be complex and hadr to maintain?                                                                        
                                                                                                                     
                                                                                                                     
INPUT                                                                                                                
=====                                                                                                                
                                                                                                                     
                                                                                                                     
 WORK.HAVONE total obs=3                                                                                             
                                                                                                                     
 RECORD_                                                                                                             
   ID       NUMBER    A1    B1    C1    A2    B2    C2                                                               
                                                                                                                     
    1         7       a     b     c     d     e     f                                                                
    2         2                                                                                                      
    3         1       a     b     c                                                                                  
                                                                                                                     
                                                                                                                     
 WORK.HAVTWO total obs=3                                                                                             
                                                                                                                     
 RECORD_                                                                                                             
   ID       NUMBER    A1X    B1X    C1X    A2X    B2X    C2X    A3X    B3X    C3X                                    
                                                                                                                     
    1         7        g      h      i      j      k      l      m      n      o                                     
    2         2        a      b      c      d      e      f                                                          
    3         1        d      e      f                                                                               
                                                                                                                     
                                                                                                                     
EXAMPLE OUTPUT                                                                                                       
==============                                                                                                       
                                                                                                                     
WORK.WANT total obs=3                                                                                                
                                                                    |  RULES                                         
 RECORD_                                                            |  =====                                         
   ID     NUMBER  A1 B1 C1  A2 B2 C2  A3 B3 C3  A4 B4 C4  A5 B5 C5  |                                                
                                                                                                                     
    1       7     a   b  c   d  e  f   g  h  i   j  k  l   m  n  o  |  Add A3  A5 to havOne using A3x  C3x           
                                                                    |                                                
                                                                                                                     
    2       2     a   b  c   d  e  f                                |  Shift A1X    C2X into A1 C2 in havOne         
                                                                                                                     
    3       1     a   b  c   d  e  f                                |  Shift A1X, B1X and C1X from havTwo            
                                                                                                                     
                                                                    |  into slots A2, B2 and C2                      
                                                                                                                     
PROCESS                                                                                                              
=======                                                                                                              
                                                                                                                     
data havCat;                                                                                                         
                                                                                                                     
  merge havOne havTwo;                                                                                               
  by record_id number;                                                                                               
                                                                                                                     
run;quit;                                                                                                            
                                                                                                                     
proc transpose data=havCat                                                                                           
     out=havCatXpo(where=(col1 ne "") rename=_name_=nam);                                                            
  by record_id number;                                                                                               
  var a1  c3x;                                                                                                       
run;quit;                                                                                                            
                                                                                                                     
data havFix(drop=cnt idx);                                                                                           
  length nam $2;                                                                                                     
  retain cnt idx 0;                                                                                                  
  set havCatXpo(rename=col1=val);                                                                                    
  by record_id;                                                                                                      
  if first.record_id then do; cnt=0; idx=0; end;                                                                     
  cnt=cnt+1;                                                                                                         
  if mod(cnt 1,3)=0 then idx=idx+1;                                                                                  
  substr(nam,2)=put(idx,1.);                                                                                         
run;quit;                                                                                                            
                                                                                                                     
proc transpose data=havFix out=want(drop=_name_);                                                                    
by record_id number;                                                                                                 
id nam;                                                                                                              
var val;                                                                                                             
run;quit;                                                                                                            
                                                                                                                     
                                                                                                                     
/*                                                                                                                   
WORK.HAVCATXPO total obs=27                                                                                          
                                                                                                                     
NOTE NO MISSINGS AND A FLEXIBLE DATA STRUCTURE                                                                       
                                                                                                                     
  RECORD_                                                                                                            
    ID       NUMBER    NAM    COL1                                                                                   
                                                                                                                     
     1         7       A1      a                                                                                     
     1         7       B1      b                                                                                     
     1         7       C1      c                                                                                     
     1         7       A2      d                                                                                     
     1         7       B2      e                                                                                     
     1         7       C2      f                                                                                     
     1         7       A1X     g                                                                                     
     1         7       B1X     h                                                                                     
     1         7       C1X     i                                                                                     
     1         7       A2X     j                                                                                     
     1         7       B2X     k                                                                                     
     1         7       C2X     l                                                                                     
     1         7       A3X     m                                                                                     
     1         7       B3X     n                                                                                     
     1         7       C3X     o                                                                                     
                                                                                                                     
     2         2       A1X     a                                                                                     
     2         2       B1X     b                                                                                     
     2         2       C1X     c                                                                                     
     2         2       A2X     d                                                                                     
     2         2       B2X     e                                                                                     
     2         2       C2X     f                                                                                     
                                                                                                                     
     3         1       A1      a                                                                                     
     3         1       B1      b                                                                                     
     3         1       C1      c                                                                                     
     3         1       A1X     d                                                                                     
     3         1       B1X     e                                                                                     
     3         1       C1X     f                                                                                     
*/                                                                                                                   
                                                                                                                     
data havFix(drop=cnt idx);                                                                                           
  length nam $2;                                                                                                     
  retain cnt idx 0;                                                                                                  
  set havCatXpo(rename=col1=val);                                                                                    
  by record_id;                                                                                                      
  if first.record_id then do; cnt=0; idx=0; end;                                                                     
  cnt=cnt+1;                                                                                                         
  if mod(cnt 1,3)=0 then idx=idx+1;                                                                                  
  substr(nam,2)=put(idx,1.);                                                                                         
run;quit;                                                                                                            
                                                                                                                     
proc transpose data=havFix out=havFicXpo(drop=_name_);                                                               
by record_id number;                                                                                                 
id nam;                                                                                                              
var val;                                                                                                             
run;quit;                                                                                                            
                                                                                                                     
                                                                                                                     
