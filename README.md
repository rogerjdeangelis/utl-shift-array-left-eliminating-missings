# utl-shift-array-left-eliminating-missings
    Keep group if any value in column 1 is in column 2                                                  
                                                                                                        
    I assume id x col1 is unique.                                                                       
                                                                                                        
      Two Solutions                                                                                     
                                                                                                        
         1. Normalize, Sort, fix names and traspose                                                     
         2. Merge (datastep to rename is left to reader) on end by                                      
             Bartosz Jablonski                                                                          
             yabwon@gmail.com                                                                           
                                                                                                        
    I have some data with an ID (grouping variable) and I want to keep observations in a group          
    if any number from column "current" shows up in column "from". Or vice versa.                       
                                                                                                        
                                                                                                        
                                                                                                        
    DATA have;                                                                                          
     input ID col1 col2;                                                                                
    cards4;                                                                                             
    1 100 .                                                                                             
    1 200 .                                                                                             
    1 300 100                                                                                           
    1 400 100                                                                                           
    1 200 .                                                                                             
    1 500 300                                                                                           
    2 300 .                                                                                             
    2 300 .                                                                                             
    2 500 100                                                                                           
    2 600 100                                                                                           
    2 700 .                                                                                             
    2 800 300                                                                                           
    3 600 100                                                                                           
    3 700 .                                                                                             
    3 800 300                                                                                           
    ;;;;                                                                                                
    run;quit;                                                                                           
                                                                                                        
    RULES                                                                                               
                                                                                                        
                                                                                                        
    data havNrm(keep=id col val);                                                                       
      set have;                                                                                         
      col="COL1";val=col1;output;                                                                       
      if col2 ne . then do;col="COL2";val=col2;output;end;                                              
    run;quit;                                                                                           
                                                                                                        
    proc sort data=havNrm out=havSrt;                                                                   
    by id val col;                                                                                      
    run;quit;                                                                                           
                                                                                                        
    data want;                                                                                          
     retain beenThere flg 0;                                                                            
     do until (last.id);                                                                                
       set havSrt;                                                                                      
       by id;                                                                                           
       if val=lag(val) and beenThere=0 then do;                                                         
         beenThere=1;                                                                                   
         flg=1;                                                                                         
       end;                                                                                             
     end;                                                                                               
     put flg=;                                                                                          
     do until (last.id);                                                                                
       set have;                                                                                        
       by id;                                                                                           
       if flg;                                                                                          
       output;                                                                                          
     end;                                                                                               
     flg=0;                                                                                             
     beenThere=0;                                                                                       
    run;quit;                                                                                           
                                                                                                        
    *____             _                                                                                 
    | __ )  __ _ _ __| |_                                                                               
    |  _ \ / _` | '__| __|                                                                              
    | |_) | (_| | |  | |_                                                                               
    |____/ \__,_|_|   \__|                                                                              
                                                                                                        
    ;                                                                                                   
                                                                                                        
        /* code */                                                   
    data WORK.HAVONE;                                            
    infile cards missover dsd dlm ="\";                          
    input                                                        
    RECORD_ID NUMBER (A1 B1 C1 A2 B2 C2) ($);                    
    cards4;                                                      
    0\7\a\b\c\d\e\f                                              
    1\7\a\b\c\d\e\f                                              
    2\2\ \ \ \ \ \                                               
    3\1\ \a\b\c\ \                                               
    ;;;;                                                         
    run;                                                         
                                                                 
    data WORK.HAVTWO;                                            
    infile cards missover dsd dlm ="\";;                         
    input                                                        
    RECORD_ID NUMBER (A1X B1X C1X A2X B2X C2X A3X B3X C3X) ($);  
    cards4;                                                      
    0\7\g\h\i\j\ \l\m\ \o                                        
    1\7\g\h\i\j\k\l\m\n\o                                        
    2\2\a\b\c\d\e\f\ \ \                                         
    3\1\d\e\f\ \ \ \ \ \                                         
    ;;;;                                                         
    run;                                                         
                                                                 
    data havCat2;                                                
     merge havOne havTwo;                                        
     by record_id number;                                        
                                                                 
     array _A_[*] _character_;                                   
                                                                 
     _K_ = 1; drop _K_ _I_;                                      
     do _I_ = 1 to dim(_A_);                                     
      if _A_[_I_] NE " " then                                    
        do;                                                      
          _A_[_K_] = _A_[_I_];                                   
          if _K_ < _I_ then _A_[_I_] = " ";                      
                                                                 
          _K_ + 1;                                               
        end;                                                     
     end;                                                        
    run;                                                         
                                                                 
                                                               
    * all that is left to do is the renaming;                                                           
                                                                                                        
                                                                                                        
                                                                                                        
                                                                                                        
                                                                                                        
                                                                                                        
