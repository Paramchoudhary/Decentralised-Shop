contract DeShop{

address seller;
address buyer ;
address arbitrator;
uint purchasePrice;
uint refundConfirmationCount;
uint purchaseConfirmationCount;

mapping(address =>bool) public hasConfirmedPurchase;
mapping(address =>bool) public hasConfirmedRefund;

constructor (
address seller_,
address buyer_,
address arbitrator_

){

    seller = seller_;
    buyer = buyer_;
    arbitrator = arbitrator_;
}
 modifier isRegisteredParticipant {
    require(msg.sender == seller || msg.sender == buyer || msg.sender == arbitrator, "Only registered participants can call this");

    _;
   }

function depositIntoEscrow() external payable{
    require(purchasePrice==0,"Already purchased");
    require(msg.sender == buyer,"only buyer can purchase items");
    purchasePrice = msg.value;
}
function confirmPurchase() external isRegisteredParticipant{
  require(!hasConfirmedPurchase[msg.sender],"Already confirmed");
  hasConfirmedPurchase[msg.sender] = true;
  purchaseConfirmationCount += 1;
   if(purchaseConfirmationCount >= 2){
       _sendfundsto(seller);
   }
}
function _sendfundsto(address recipient) private {
(bool success,) = recipient.call{value: purchasePrice}("");
require(success,"sending funds failed");
}
function confirmRefund() external isRegisteredParticipant{
   
    require(!hasConfirmedRefund[msg.sender],"Already refunded");
    hasConfirmedRefund[msg.sender] = true;
    refundConfirmationCount += 1;
    if (purchaseConfirmationCount >= 2) {
       _sendfundsto(seller);
     }

}

}
