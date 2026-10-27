struct FAttack{
    UPROPERTY()
    FString AttackName;
    UPROPERTY()
    float Weight;
}

class AJesterBoss :AActor{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;
    UPROPERTY(DefaultComponent)
    UStaticMeshComponent JesterBody;
    UPROPERTY(DefaultComponent)
    UHealComponent Health;

    UPROPERTY(DefaultComponent)
    UStaticMeshComponent RightHand;
    UPROPERTY(DefaultComponent)
    UStaticMeshComponent LeftHand;
    UPROPERTY()
    FAttack Left;
    UPROPERTY()
    FAttack Right;
    UPROPERTY()
    FAttack Up;
    UPROPERTY()
    FAttack Down;
    UPROPERTY()
    FAttack Slam;
    UPROPERTY()
    FAttack Cross;

    TArray<FAttack> Attacks;
    //contains a randomised index of all the attacks used for selection
    TArray<int> AttackOrder;

    //add all attack patterns into there own arrays so they can be triggered seperatly

    bool CurrentlyAttacking = false;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Health.SetHealth(100);
        Attacks.Add(Left);
        Attacks.Add(Right);
        Attacks.Add(Up);
        Attacks.Add(Down);
        Attacks.Add(Slam);

        //base attack order
        AttackOrder.Add(0);
        AttackOrder.Add(1);
        AttackOrder.Add(2);
        AttackOrder.Add(3);
        AttackOrder.Add(4);
    }


    void DecideAttack(){
        if(Health.CurrentHealth <= Health.MaxHealth /2.0f){
           // add so it randomises how much to remove from a random amount of weight from other attacks weights
           
           Attacks.Add(Cross);
           AttackOrder.Add(5);
           
        }

        if(!CurrentlyAttacking){
            //decide on attack
            AttackOrder.Shuffle();
            float RandomNumber = Math::RandRange(0.0f, 100.0f);
            float CurrentTotalWeight = 0;
            int AttackIndex = 0;
            for(int i = 0; i < AttackOrder.Num();i++){
                CurrentTotalWeight += Attacks[AttackOrder[i]].Weight;
                if(RandomNumber < CurrentTotalWeight){
                    //use this attack
                    AttackIndex = AttackOrder[i];
                    break;
                }
            }
            //use attack now
            //fuck this shit is not pretty
            float WeightChange = Math::RandRange(1.0f, 7.0f);
            if(Attacks[AttackIndex].AttackName == "Left"){
                LeftScreenAttack();
            }else if(Attacks[AttackIndex].AttackName == "Right"){
                RightScreenAttack();
            }else if(Attacks[AttackIndex].AttackName == "Up"){
                UpScreenAttack();
            }else if(Attacks[AttackIndex].AttackName == "Down"){
                DownScreenAttack();
            }else if(Attacks[AttackIndex].AttackName == "Slam"){
                SlamAttack();
            }else if(Attacks[AttackIndex].AttackName == "Cross"){
                CrossAttack();
            }
            //chnages weights around to make the fight more intresting
            if(Attacks[AttackIndex].Weight - WeightChange <= 0){
                    float diffrence = Attacks[AttackIndex].Weight - WeightChange;
                    diffrence += diffrence +1;
                    WeightChange = diffrence;
                }
                Attacks[AttackIndex].Weight -= WeightChange;
                Attacks[Math::RandRange(0, Attacks.Num()-1)].Weight += WeightChange;
        }


    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        

    }

    void LeftScreenAttack(){

    }

    void RightScreenAttack(){
        
    }

    void UpScreenAttack(){
        
    }

    void DownScreenAttack(){
        
    }

    void CrossAttack(){

    }

    void SlamAttack(){
        
    }

}