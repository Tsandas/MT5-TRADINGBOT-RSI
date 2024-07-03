#include <Trade/Trade.mqh>

CTrade trade;

input int Lots=1;
ulong posTicket;

int RSIHandle;

int OnInit(){       
   RSIHandle = iRSI(_Symbol,PERIOD_CURRENT,14,PRICE_CLOSE);  
   
   
   return(INIT_SUCCEEDED);
}

void OnTick(){
   double rsi[];
   CopyBuffer(RSIHandle,0,1,1,rsi);
   
  
   if(rsi[0] > 70){
      //close buy pos if we get sell signal, works better without it
      if(posTicket > 0 && PositionSelectByTicket(posTicket)){
         int posType = (int)PositionGetInteger(POSITION_TYPE);
         if(posType == POSITION_TYPE_BUY){
               trade.PositionClose(posTicket);
               posTicket=0;
            }   
      } 
      if(posTicket<=0){  
         trade.Sell(Lots,_Symbol);
         posTicket = trade.ResultOrder();
      }
   }else if(rsi[0]<30){
      if(posTicket > 0 && PositionSelectByTicket(posTicket)){
         int posType = (int)PositionGetInteger(POSITION_TYPE);
         if(posType == POSITION_TYPE_SELL){
               trade.PositionClose(posTicket);
               posTicket=0;
            }   
      }
        
      if(posTicket<=0){
         trade.Buy(Lots,_Symbol);
         posTicket = trade.ResultOrder();
      }
   }
   
   if(PositionSelectByTicket(posTicket)){
      double posPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double posSl = PositionGetDouble(POSITION_SL);
      double posTp = PositionGetDouble(POSITION_TP);
      int posType = (int)PositionGetInteger(POSITION_TYPE);
      
      if(posType == POSITION_TYPE_BUY){
         if(posSl == 0){
            double sl = posPrice - 0.00300;
            double tp = posPrice + 0.00500;
            trade.PositionModify(posTicket,sl,tp);
         }
      }else{
         if(posSl==0){
            double sl = posPrice + 0.00300;
            double tp = posPrice - 0.00500;
            trade.PositionModify(posTicket,sl,tp);
         }
      }   
   }else{
      posTicket = 0;
   }
   
}
