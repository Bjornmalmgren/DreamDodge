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
    UPROPERTY(DefaultComponent, Attach = RightHand)
    UBoxComponent RightHandHitBox;
    UPROPERTY(DefaultComponent)
    UStaticMeshComponent LeftHand;
    UPROPERTY(DefaultComponent, Attach = LeftHand)
    UBoxComponent LeftHandHitBox;
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

    UPROPERTY(DefaultComponent)
    UAudioComponent Audio;

    FVector HandsDefaultPosition = FVector(0,440,0);

    UPROPERTY()
    TArray<FAttack> Attacks;
    //contains a randomised index of all the attacks used for selection
    TArray<int> AttackOrder;

    //add all attack patterns into there own arrays so they can be triggered seperatly
    UPROPERTY()
    TArray<ABulletSpawner> TopSpawners;
    UPROPERTY()
    TArray<ABulletSpawner> BottomSpawners;
    UPROPERTY()
    TArray<ABulletSpawner> LeftSpawners;
    UPROPERTY()
    TArray<ABulletSpawner> RightSpawners;
    UPROPERTY()
    TArray<ABulletSpawner> CrossSpawners;
    UPROPERTY()
    TArray<AActor> JesterLocations;


    bool CurrentlyAttacking = false;

    //right hand attacking variables
    bool RightHandAttacking = false;
    UPROPERTY()
    FString CurrentRightHandAttack;
    bool RightInAttackPosition = false;
    FVector RightPositionWhenReady;
    FVector RightPositionWhenDone;
    float RightHandSpeed = 15;
    bool RightSlamAttack = false;
    UPROPERTY()
    TArray<ABulletSpawner> RightSlamAttackSpawners;
    int RightFollowPatternBetweenSpawnersIndex  = 0;
    bool RightFollowPatternBetweenSpawners = false;
    bool RightSlamDown = false;
    int TotalRightUnitsDown = 200;

    //left hand attacking variables
    bool LeftHandAttacking = false;
    bool LeftInAttackPosition = false;
    FVector LeftPositionWhenReady;
    FVector LeftPositionWhenDone;
    UPROPERTY()
    FString CurrentLeftHandAttack;
    float LeftHandSpeed = 15;
    bool LeftSlamAttack = false;
    TArray<ABulletSpawner> LeftSlamAttackSpawners;
    int LeftFollowPatternBetweenSpawnersIndex  = 0;
    bool LeftFollowPatternBetweenSpawners = false;
    bool LeftSlamDown = false;
    int TotalLeftUnitsDown = 200;

    //the hands move and trigger the spawner so a queue is made the keep track it will be FIFO
    UPROPERTY()
    TArray<FVector> LeftPositionalQueue;
    UPROPERTY()
    TArray<FVector> RightPositionalQueue;
    //variables for moving the hands
    bool MoveLeftHand = false;
    bool MoveRightHand = false;
    float DelayBetweenMovements = 0.2f;


    //wave templet for the spawners
    FBulletWaveTemplate LeftAttackTemplete;
    FBulletWaveTemplate RightAttackTemplete;

    //
    float GlobalBulletSpeed = 10;

    UPROPERTY()
    FBulletWaveTemplate TopSlamTemplate();
    UPROPERTY()
    FBulletWaveTemplate BottomSlamTemplate();

    APlayer Player;
    AGameManager GameManager;
    bool FirstTimeUnder60 = true;
    bool FirstTimeUnder30 = true;

    int PhaseOfBoss = 1;

    //audio
    UPROPERTY()
    float PlayBackDuration;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Right.AttackName = "Right";
        Right.Weight = 20.0f;
        Left.AttackName = "Left";
        Left.Weight = 20.0f;

        Up.AttackName = "Up";
        Up.Weight = 20.0f;
        Down.AttackName = "Down";
        Down.Weight = 20.0f;
        Down.AttackName = "Slam";
        Down.Weight = 20.0f;

        Health.SetHealth(90);

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

        //finding spawners and its locations
        GetAllActorsOfClassWithTag(n"JesterLocations", JesterLocations);

        TArray<ABulletSpawner> AllSpawners;
        GetAllActorsOfClass(ABulletSpawner, AllSpawners);
        
        for(auto Spawner : AllSpawners){
            if(Spawner.GetActorNameOrLabel().Contains("Cross")){
                CrossSpawners.Add(Spawner);
            }else if(Spawner.GetActorNameOrLabel().Contains("Down")){
                BottomSpawners.Add(Spawner);
            }
            else if(Spawner.GetActorNameOrLabel().Contains("Left")){
                LeftSpawners.Add(Spawner);
            }
            else if(Spawner.GetActorNameOrLabel().Contains("Right")){
                RightSpawners.Add(Spawner);
            }
            else if(Spawner.GetActorNameOrLabel().Contains("Up")){
                TopSpawners.Add(Spawner);
            }
        }

        SortSpawner();
        TArray<APlayer> players;
        GetAllActorsOfClass(APlayer,players);
        Player = players[0];

        TArray<AGameManager> GameManagers;
        GetAllActorsOfClass(AGameManager,GameManagers);
        GameManager = GameManagers[0];
        
        Audio.Sound = GameManager.DreamMusic[0];
        Audio.Play();
        TakeDamage(60);
    }


    UFUNCTION()
    void SortSpawner(){
         TArray<ABulletSpawner> tempLeft;
        
       

        //Spawners.Empty();
        int CurrentIndexLeft = 1;
        for(int i = 0; i<LeftSpawners.Num();i++){
            for(int j = 0; j<LeftSpawners.Num();j++){
                FString Left;
                FString Right;
                LeftSpawners[j].GetActorNameOrLabel().Split("_",Left,Right);
                int Value = String::Conv_StringToInt(Right);
                if(Value == CurrentIndexLeft){
                    tempLeft.Add(LeftSpawners[j]);
                    CurrentIndexLeft++;
                    break;
                }
            }
        }

        LeftSpawners = tempLeft;


        TArray<ABulletSpawner> tempRight;
        
       

        //Spawners.Empty();
        int CurrentIndexRight = 1;
        for(int i = 0; i<RightSpawners.Num();i++){
            for(int j = 0; j<RightSpawners.Num();j++){
                FString Left;
                FString Right;
                RightSpawners[j].GetActorNameOrLabel().Split("_",Left,Right);
                int Value = String::Conv_StringToInt(Right);
                if(Value == CurrentIndexRight){
                    tempRight.Add(RightSpawners[j]);
                    CurrentIndexRight++;
                    break;
                }
            }
        }

        RightSpawners = tempRight;


        TArray<ABulletSpawner> tempUp;
        
       

        //Spawners.Empty();
        int CurrentIndexUp = 1;
        for(int i = 0; i<TopSpawners.Num();i++){
            for(int j = 0; j<TopSpawners.Num();j++){
                FString Left;
                FString Right;
                TopSpawners[j].GetActorNameOrLabel().Split("_",Left,Right);
                int Value = String::Conv_StringToInt(Right);
                if(Value == CurrentIndexUp){
                    tempUp.Add(TopSpawners[j]);
                    CurrentIndexUp++;
                    break;
                }
            }
        }

        TopSpawners = tempUp;


        TArray<ABulletSpawner> tempDown;
        
       

        //Spawners.Empty();
        int CurrentIndexDown = 1;
        for(int i = 0; i<BottomSpawners.Num();i++){
            for(int j = 0; j<BottomSpawners.Num();j++){
                FString Left;
                FString Right;
                BottomSpawners[j].GetActorNameOrLabel().Split("_",Left,Right);
                int Value = String::Conv_StringToInt(Right);
                if(Value == CurrentIndexDown){
                    tempDown.Add(BottomSpawners[j]);
                    CurrentIndexDown++;
                    break;
                }
            }
        }

        BottomSpawners = tempDown;

        TArray<ABulletSpawner> tempCross;
        
       

        //Spawners.Empty();
        int CurrentIndexCross = 1;
        for(int i = 0; i<CrossSpawners.Num();i++){
            for(int j = 0; j<CrossSpawners.Num();j++){
                FString Left;
                FString Right;
                CrossSpawners[j].GetActorNameOrLabel().Split("_",Left,Right);
                int Value = String::Conv_StringToInt(Right);
                if(Value == CurrentIndexCross){
                    tempCross.Add(CrossSpawners[j]);
                    CurrentIndexCross++;
                    break;
                }
            }
        }

        CrossSpawners = tempCross;
        
    }

    UFUNCTION()
    void DecideAttack(){
        

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
            int RandomAttack = Math::RandRange(0, Attacks.Num()-1);
            Attacks[RandomAttack].Weight += WeightChange;
            
        }


    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {

        DecideAttack();
        if(MoveLeftHand)
            if(CurrentLeftHandAttack == "Slam"){
                SetupLeftSlamAttack();
            }else{
                MoveLeftJesterHands();
            }
            
        if(MoveRightHand)
            if(CurrentRightHandAttack == "Slam"){
                SetupRightSlamAttack();
            }else{
                MoveRightJesterHands();
            }
            

    }


    UFUNCTION()
    void SetupRightSlamAttack(){
        if(!RightSlamDown){
            TotalRightUnitsDown = 500;
            FVector DirectionToDesired =  Player.ActorLocation + FVector(0,0,500) - RightHand.WorldLocation;
            DirectionToDesired.Normalize();
            RightHandSpeed = 10;
            RightHand.SetWorldLocation(RightHand.WorldLocation + DirectionToDesired * RightHandSpeed);
        }else{
            RightHand.SetWorldLocation(RightHand.WorldLocation -FVector(0,0,1)*15);
            TotalRightUnitsDown -= 15;
            if(TotalRightUnitsDown <= 0){
                CurrentRightHandAttack= "";
                RightPositionalQueue.Add(ActorLocation + -HandsDefaultPosition);
                RightHandSpeed = 10+ 5*PhaseOfBoss;
                MoveRightJesterHands();
            }
            
        }
        
    }
    UFUNCTION()
    void RightSlamAttackExecution(){
        RightSlamDown = true;
    }

    UFUNCTION()
    void SetupLeftSlamAttack(){
        if(!LeftSlamDown){
            TotalLeftUnitsDown = 500;
            FVector DirectionToDesired =  Player.ActorLocation + FVector(0,0,500) - LeftHand.WorldLocation;
            DirectionToDesired.Normalize();
            LeftHandSpeed = 10;
            LeftHand.SetWorldLocation(LeftHand.WorldLocation + DirectionToDesired * LeftHandSpeed);
        }else{
            LeftHand.SetWorldLocation(LeftHand.WorldLocation -FVector(0,0,1)*15);
            TotalLeftUnitsDown -= 15;
            if(TotalLeftUnitsDown <= 0){
                CurrentLeftHandAttack= "";
                LeftPositionalQueue.Add(ActorLocation + HandsDefaultPosition);
                LeftHandSpeed = 10+5*PhaseOfBoss;
                MoveLeftJesterHands();
            }
            
        }
        
    }
    UFUNCTION()
    void LeftSlamAttackExecution(){
        LeftSlamDown = true;
    }

    void MoveLeftJesterHands(){  
        if(LeftPositionalQueue.Num() <= 0){
                
                return;
            }     
        if(LeftHand.WorldLocation.Distance(LeftPositionalQueue[0]) < 10){
            if(LeftPositionWhenReady == LeftPositionalQueue[0]){
                LeftInAttackPosition = true;
            }
            if(LeftPositionWhenDone == LeftPositionalQueue[0]){
                 LeftInAttackPosition = false;
            }
               
            LeftHand.WorldLocation = LeftPositionalQueue[0];
            LeftPositionalQueue.RemoveAt(0);
            MoveLeftHand = false;
            if(LeftPositionalQueue.Num() <= 0){
                CurrentlyAttacking = false;
                ResetNumbersBetweenAttacks();
                return;
            }else{
                //add in delay
                System::SetTimer(this,n"ContinueMovingLeftHand",DelayBetweenMovements,false,false);
            }
                
        }
        FVector DirectionToDesired = LeftPositionalQueue[0] - LeftHand.WorldLocation;
        DirectionToDesired.Normalize();
        //System::DrawDebugArrow(LeftHand.WorldLocation,LeftHand.WorldLocation + DirectionToDesired,4,FLinearColor::Red, 10000, 10 );
        LeftHand.SetWorldLocation(LeftHand.WorldLocation + DirectionToDesired * LeftHandSpeed);

    }

    void MoveRightJesterHands(){    
        if(RightPositionalQueue.Num() <= 0){
        
            return;
        }    
        if(RightHand.WorldLocation.Distance(RightPositionalQueue[0]) < 10){
            if(RightPositionWhenReady == RightPositionalQueue[0])
                RightInAttackPosition = true;
            if(RightPositionWhenDone == RightPositionalQueue[0])
                RightInAttackPosition = false;
            RightHand.WorldLocation = RightPositionalQueue[0];
            RightPositionalQueue.RemoveAt(0);
            MoveRightHand = false;
            if(RightPositionalQueue.Num() <= 0){
                ResetNumbersBetweenAttacks();
                CurrentlyAttacking = false;
                return;
            }else{
                //add in delay
                System::SetTimer(this,n"ContinueMovingRightHand",DelayBetweenMovements,false,false);
            }
                
        }
        FVector DirectionToDesired = RightPositionalQueue[0] - RightHand.WorldLocation;
        DirectionToDesired.Normalize();
        //System::DrawDebugArrow(LeftHand.WorldLocation,LeftHand.WorldLocation + DirectionToDesired,4,FLinearColor::Red, 10000, 10 );
        RightHand.SetWorldLocation(RightHand.WorldLocation + DirectionToDesired * RightHandSpeed);

    }

    UFUNCTION()
    void ContinueMovingLeftHand(){
        MoveLeftHand = true;
    }

    UFUNCTION()
    void ContinueMovingRightHand(){
        MoveRightHand = true;
    }

    UFUNCTION()
    void TriggerSpeciicSpawners(TArray<ABulletSpawner> Spawners, FString WhichHand){
        int i = 0;
        FBulletWaveTemplate Template;
        if(WhichHand == "Left"){
            Template = LeftAttackTemplete;
        }else if (WhichHand == "Right"){
            Template = RightAttackTemplete;
        }else{
            return;
        }
        for(auto Spawner : Spawners){
            if(LeftFollowPatternBetweenSpawners || RightFollowPatternBetweenSpawners){
                Template.BulletType = Template.DimensionPattern[i];

                Spawner.SpawnBulletWave(Template);
                i++;
                if(i >= Template.DimensionPattern.Num()){
                    i = 0;
                }
                    
            }else{
                Spawner.SpawnBulletWave(Template);
            }
        }
    }
    UFUNCTION()
    void RightHandOverlap(AActor OtherActor){
        //always right hand
        if(CurrentRightHandAttack == "Cross" && OtherActor.GetActorNameOrLabel().Contains(CurrentRightHandAttack) && RightInAttackPosition && !RightSlamAttack){
            ABulletSpawner  BulletSpawner = Cast<ABulletSpawner>(OtherActor);
            BulletSpawner.BulletWave.BulletSpeed = GlobalBulletSpeed;
            BulletSpawner.SpawnBulletWave(BulletSpawner.BulletWave);
        }else if(OtherActor.GetActorNameOrLabel().Contains(CurrentRightHandAttack) && RightInAttackPosition && !RightSlamAttack){
            RightAttackTemplete.DimensionPattern.Shuffle();
            Cast<ABulletSpawner>(OtherActor).SpawnBulletWave(RightAttackTemplete);
        }else if(OtherActor.GetActorNameOrLabel().Contains(CurrentRightHandAttack) && RightInAttackPosition && RightSlamAttack){
            TriggerSpeciicSpawners(RightSlamAttackSpawners, "Right");
            RightInAttackPosition = false;
        }
    }

    UFUNCTION()
    void LeftHandOverlap(AActor OtherActor){
        //always left hand
        if(CurrentLeftHandAttack == "Cross" && OtherActor.GetActorNameOrLabel().Contains(CurrentLeftHandAttack) && LeftInAttackPosition && !LeftSlamAttack){
            ABulletSpawner  BulletSpawner = Cast<ABulletSpawner>(OtherActor);
            BulletSpawner.BulletWave.BulletSpeed = GlobalBulletSpeed;
            BulletSpawner.SpawnBulletWave(BulletSpawner.BulletWave);
        }else if(OtherActor.GetActorNameOrLabel().Contains(CurrentLeftHandAttack) && LeftInAttackPosition && !LeftSlamAttack){
            LeftAttackTemplete.DimensionPattern.Shuffle();
            Cast<ABulletSpawner>(OtherActor).SpawnBulletWave(LeftAttackTemplete);
        }else if(OtherActor.GetActorNameOrLabel().Contains(CurrentLeftHandAttack) && LeftInAttackPosition && LeftSlamAttack){
            TriggerSpeciicSpawners(LeftSlamAttackSpawners, "Left");
            LeftInAttackPosition = false;
        }
    }

    void LeftScreenAttack(){
        //takes left hand and activates the spawners with a downward motion: shoots one bullet
        //need to fix a static version like the slam from the top
        LeftAttackTemplete.BulletDirection = EMovementDirection::Right;
        LeftAttackTemplete.BulletSpeed = GlobalBulletSpeed;
        LeftAttackTemplete.DimensionPattern.Add(EDimension::Dream);
        LeftAttackTemplete.DimensionPattern.Add(EDimension::Dream);
        LeftAttackTemplete.DimensionPattern.Add(EDimension::Nightmare);
        LeftAttackTemplete.DimensionPattern.Add(EDimension::Nightmare);
        LeftAttackTemplete.DimensionPattern.Add(EDimension::Normal);
        LeftAttackTemplete.EnablePattern = true;
        LeftAttackTemplete.RepeatPattern = true;

        LeftPositionWhenReady = LeftSpawners[0].ActorLocation + FVector(0,100,300);
        LeftPositionWhenDone = LeftSpawners.Last().ActorLocation + FVector(0,100,-100);

        LeftPositionalQueue.Add(LeftSpawners[0].ActorLocation + FVector(0,100,300));
        LeftPositionalQueue.Add(LeftSpawners.Last().ActorLocation + FVector(0,100,-100));
        LeftPositionalQueue.Add(ActorLocation + HandsDefaultPosition);

        LeftHandAttacking = true;
        CurrentLeftHandAttack = "Left";
        MoveLeftHand = true;
        CurrentlyAttacking = true;
    }

    void RightScreenAttack(){   
        //same as left but from the right

        RightAttackTemplete.BulletDirection = EMovementDirection::Left;
        RightAttackTemplete.BulletSpeed = GlobalBulletSpeed;
        RightAttackTemplete.DimensionPattern.Add(EDimension::Dream);
        RightAttackTemplete.DimensionPattern.Add(EDimension::Dream);
        RightAttackTemplete.DimensionPattern.Add(EDimension::Nightmare);
        RightAttackTemplete.DimensionPattern.Add(EDimension::Nightmare);
        RightAttackTemplete.DimensionPattern.Add(EDimension::Normal);
        RightAttackTemplete.EnablePattern = true;
        RightAttackTemplete.RepeatPattern = true;

        RightPositionWhenDone = RightSpawners[0].ActorLocation + FVector(0,-100,300);
        RightPositionWhenReady = RightSpawners.Last().ActorLocation + FVector(0,-100,-100);

        RightPositionalQueue.Add(RightSpawners.Last().ActorLocation + FVector(0,-100,-100));
        RightPositionalQueue.Add(RightSpawners[0].ActorLocation + FVector(0,-100,300));
        
        RightPositionalQueue.Add(ActorLocation + -HandsDefaultPosition);
        RightHandAttacking = true;
        CurrentRightHandAttack = "Right";
        MoveRightHand = true;
        CurrentlyAttacking = true;
    }

    void UpScreenAttack(){
        //slams the top if the map and send bullets down 50:50 which side
        //really really stupid and hardcoded
        float Side = Math::RandRange(0.0f, 100.0f);
        if(Side < 50.0f){
            LeftHandSlamAttack(TopSpawners,2,2,2,"Up",TopSlamTemplate,true,FVector(0,0,600),FVector(0,0,100),4);
        }else{
            RightHandSlamAttack(TopSpawners,7,2,2,"Up",TopSlamTemplate,true,FVector(0,0,600),FVector(0,0,100),4);
        }
        CurrentlyAttacking = true;


    }

    void DownScreenAttack(){
        //same as up but defies gravity
        float Side = Math::RandRange(0.0f, 90.0f);
        if(Side < 30.0f){
            LeftHandSlamAttack(BottomSpawners,0,1,0,"Down",BottomSlamTemplate,true,FVector(0,0,-600),FVector(0,0,-100),4);
        }else if(Side < 60.0f){
            float WhichHand = Math::RandRange(0.0f, 100.0f);
            if(WhichHand < 50.0f){
                LeftHandSlamAttack(BottomSpawners,3,2,1,"Down",BottomSlamTemplate,true,FVector(0,0,-600),FVector(0,0,-100),4);
            }else{
                RightHandSlamAttack(BottomSpawners,3,2,1,"Down",BottomSlamTemplate,true,FVector(0,0,-600),FVector(0,0,-100),4);
            }
        }else{
            RightHandSlamAttack(BottomSpawners,6,1,0,"Down",BottomSlamTemplate,true,FVector(0,0,-600),FVector(0,0,-100),4);
        }
        CurrentlyAttacking = true;
    }

    void CrossAttack(){
        //swipes hand throught the cross and triggers them
        LeftPositionWhenReady = CrossSpawners[27].ActorLocation + FVector(0,300,300);
        LeftPositionWhenDone = CrossSpawners[13].ActorLocation - FVector(0,300,300);

        LeftPositionalQueue.Add(CrossSpawners[27].ActorLocation + FVector(0,300,300));
        LeftPositionalQueue.Add(CrossSpawners[13].ActorLocation - FVector(0,300,300));
        LeftPositionalQueue.Add(ActorLocation + HandsDefaultPosition);

        LeftHandAttacking = true;
        CurrentLeftHandAttack = "Cross";
        MoveLeftHand = true;
        


        RightPositionWhenReady = CrossSpawners[41].ActorLocation + FVector(0,-300,300);
        RightPositionWhenDone = CrossSpawners[42].ActorLocation - FVector(0,-300,300);

        RightPositionalQueue.Add(CrossSpawners[41].ActorLocation + FVector(0,-300,300));
        RightPositionalQueue.Add(CrossSpawners[42].ActorLocation - FVector(0,-300,300));
        RightPositionalQueue.Add(ActorLocation + -HandsDefaultPosition);

        RightHandAttacking = true;
        CurrentRightHandAttack = "Cross";
        MoveRightHand = true;

        CurrentlyAttacking = true;
    }

    void SlamAttack(){
        //slams where the player is

        float WhichHand = Math::RandRange(0.0f,100.0f);
        
        if(WhichHand < 50.0f){
            LeftHandAttacking = true;
            CurrentLeftHandAttack = "Slam";
            MoveLeftHand = true;

            System::SetTimer(this,n"LeftSlamAttackExecution",3,false,false);
        }else{
            RightHandAttacking = true;
            CurrentRightHandAttack = "Slam";
            MoveRightHand = true;

            System::SetTimer(this,n"RightSlamAttackExecution",3,false,false);
        }
        CurrentlyAttacking = true;
    }

    void ResetNumbersBetweenAttacks(){
        
        if(!MoveLeftHand){
            LeftFollowPatternBetweenSpawners = false;
            LeftSlamAttack = false;
            LeftSlamAttackSpawners.Empty();
        }
        
        if(!MoveRightHand){
            RightFollowPatternBetweenSpawners = false;
            RightSlamAttack = false;
            RightSlamAttackSpawners.Empty();    
        }
        
    }
    //position modifier 1 and 2 add the distance between the middle spawner to make the hands not clip
    UFUNCTION()
    void RightHandSlamAttack(TArray<ABulletSpawner> Spawners, int StartIndex, int IndexExtentPositive, int IndexExtentNegative, FString HandAttackDirection, FBulletWaveTemplate Template, bool FollowPatternBetweenSpawners, FVector PositionModefire1,FVector PositionModefire2, int HowManySlams){
            
            for(int i = 0; i < HowManySlams; i++){
                RightPositionalQueue.Add(Spawners[StartIndex].ActorLocation + PositionModefire1);
                if(i != HowManySlams-1){
                    RightPositionalQueue.Add(Spawners[StartIndex].ActorLocation + PositionModefire2);
                }else{
                    RightPositionalQueue.Add(Spawners[StartIndex].ActorLocation + PositionModefire2+FVector(0,0,1));
                }                
            }
            //reset hand position
            RightPositionalQueue.Add(ActorLocation + -HandsDefaultPosition);

            RightPositionWhenReady = Spawners[StartIndex].ActorLocation + PositionModefire1;
            RightPositionWhenDone = Spawners[StartIndex].ActorLocation + PositionModefire2+FVector(0,0,1);

            RightAttackTemplete = Template;
            CurrentRightHandAttack = HandAttackDirection;

            for(int i = StartIndex-IndexExtentNegative; i <= StartIndex-1; i++){
                 RightSlamAttackSpawners.Add(Spawners[i]);
            }
            for(int i = StartIndex; i <= IndexExtentPositive + StartIndex; i++){
                 RightSlamAttackSpawners.Add(Spawners[i]);
            }
            
           
            RightFollowPatternBetweenSpawners = FollowPatternBetweenSpawners;
            RightHandAttacking = true;
            MoveRightHand = true;
            RightSlamAttack = true;
    }
    //position modifier 1 and 2 add the distance between the middle spawner to make the hands not clip
    UFUNCTION()
    void LeftHandSlamAttack(TArray<ABulletSpawner> Spawners, int StartIndex, int IndexExtentPositive, int IndexExtentNegative, FString HandAttackDirection, FBulletWaveTemplate Template, bool FollowPatternBetweenSpawners, FVector PositionModefire1,FVector PositionModefire2, int HowManySlams){
            

            for(int i = 0; i < HowManySlams; i++){
                LeftPositionalQueue.Add(Spawners[StartIndex].ActorLocation + PositionModefire1);
                if(i != HowManySlams-1){
                    LeftPositionalQueue.Add(Spawners[StartIndex].ActorLocation + PositionModefire2);
                }else{
                    LeftPositionalQueue.Add(Spawners[StartIndex].ActorLocation + PositionModefire2+FVector(0,0,1));
                }                
            }
            
            LeftPositionalQueue.Add(ActorLocation + HandsDefaultPosition);

            LeftPositionWhenReady = Spawners[StartIndex].ActorLocation + PositionModefire1;
            LeftPositionWhenDone = Spawners[StartIndex].ActorLocation + PositionModefire2+FVector(0,0,1);
            LeftAttackTemplete = Template;
            CurrentLeftHandAttack = HandAttackDirection;

            for(int i = StartIndex-IndexExtentNegative; i <= StartIndex-1; i++){
                 LeftSlamAttackSpawners.Add(Spawners[i]);
            }
            for(int i = StartIndex; i <= IndexExtentPositive + StartIndex; i++){
                 LeftSlamAttackSpawners.Add(Spawners[i]);
            }
           
            LeftFollowPatternBetweenSpawners = FollowPatternBetweenSpawners;
            LeftHandAttacking = true;
            MoveLeftHand = true;
            LeftSlamAttack = true;
    }

    UFUNCTION()
    void TakeDamage(int amount){
        Health.DecreaseHealth(amount);
        if(Health.CurrentHealth <= Health.MaxHealth-Health.MaxHealth /3.0f && FirstTimeUnder60){
            //phase 2
            FirstTimeUnder60 = false;
            PhaseOfBoss = 2;
            GlobalBulletSpeed = 10+5*PhaseOfBoss;
            Attacks.Add(Cross);
            AttackOrder.Add(5);

            TopSlamTemplate.BulletSpeed = GlobalBulletSpeed;
            BottomSlamTemplate.BulletSpeed = GlobalBulletSpeed;
        }
        if(Health.CurrentHealth <= Health.MaxHealth /3.0f && FirstTimeUnder30){
            FirstTimeUnder30 = false;
            PhaseOfBoss = 3;
            GlobalBulletSpeed = 10+5*PhaseOfBoss;
        }
       
    }

    UFUNCTION()
    void SwapDimensions(EDimension NewDimension){
        if(NewDimension == EDimension::Dream){
            Audio.Stop();
            float StopTime = Audio.Sound.Duration*PlayBackDuration;
            Audio.Sound = GameManager.DreamMusic[PhaseOfBoss-1];
            Audio.Play(StopTime);
        }else if(NewDimension == EDimension::Nightmare){
            Audio.Stop();
            
            float StopTime = Audio.Sound.Duration *PlayBackDuration;
            Print(""+StopTime);
            Audio.Sound = GameManager.NightmareMusic[PhaseOfBoss-1];
            Audio.Play(StopTime);
        }
    }

}