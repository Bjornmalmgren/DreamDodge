class AJesterHand : AActor{
    UPROPERTY(DefaultComponent,RootComponent)
    USceneComponent Root;
    UPROPERTY(DefaultComponent)
    UStaticMeshComponent HandMesh;
    UPROPERTY(DefaultComponent)
    UBoxComponent OverlapArea;

    //variables
    bool HandAttacking = false;
    bool InAttackPosition = false;
    FVector PositionWhenReady;
    FVector PositionWhenDone;
    UPROPERTY()
    FString CurrentHandAttack;
    float HandSpeed = 15;
    bool SlamAttack = false;
    TArray<ABulletSpawner> SlamAttackSpawners;
    int FollowPatternBetweenSpawnersIndex  = 0;
    bool FollowPatternBetweenSpawners = false;
    bool SlamDown = false;
    int TotalUnitsDown = 200;    
    FVector HandDefaultPosition = FVector(0.000006,460.000000,2410.000000);
    FBulletWaveTemplate AttackTemplete;
    bool MoveHand = false;

    bool CurrentlyAttacking = false;
    float DelayBetweenMovements = 0.2f;
    UPROPERTY()
    TArray<FVector> PositionalQueue;

    int PhaseOfBoss = 1;
    float GlobalBulletSpeed = 10;


    //managers and player acces
    APlayer Player;
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
         TArray<APlayer> players;
        GetAllActorsOfClass(APlayer,players);
        Player = players[0];
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        if(MoveHand)
            if(CurrentHandAttack == "Slam"){
                SetupSlamAttack();
            }else{
                MoveJesterHands();
            }
    }

    UFUNCTION(BlueprintOverride)
    void ActorBeginOverlap(AActor OtherActor)
    {
        if(CurrentHandAttack == "Cross" && OtherActor.GetActorNameOrLabel().Contains(CurrentHandAttack) && InAttackPosition && !SlamAttack){
            ABulletSpawner  BulletSpawner = Cast<ABulletSpawner>(OtherActor);
            BulletSpawner.BulletWave.BulletSpeed = GlobalBulletSpeed;
            BulletSpawner.SpawnBulletWave(BulletSpawner.BulletWave);
        }else if(OtherActor.GetActorNameOrLabel().Contains(CurrentHandAttack) && InAttackPosition && !SlamAttack){
            AttackTemplete.DimensionPattern.Shuffle();
            Cast<ABulletSpawner>(OtherActor).SpawnBulletWave(AttackTemplete);
        }else if(OtherActor.GetActorNameOrLabel().Contains(CurrentHandAttack) && InAttackPosition && SlamAttack){
            TriggerSpeciicSpawners(SlamAttackSpawners);
            InAttackPosition = false;
        }
    }

    UFUNCTION()
    void HandSlamAttack(TArray<ABulletSpawner> Spawners, int StartIndex, int IndexExtentPositive, int IndexExtentNegative, FString HandAttackDirection, FBulletWaveTemplate Template, bool FollowPatternBetweenSpawnersInput, FVector PositionModefire1,FVector PositionModefire2, int HowManySlams){
            

            for(int i = 0; i < HowManySlams; i++){
                PositionalQueue.Add(Spawners[StartIndex].ActorLocation + PositionModefire1);
                if(i != HowManySlams-1){
                    PositionalQueue.Add(Spawners[StartIndex].ActorLocation + PositionModefire2);
                }else{
                    PositionalQueue.Add(Spawners[StartIndex].ActorLocation + PositionModefire2+FVector(0,0,1));
                }                
            }
            
            PositionalQueue.Add(HandDefaultPosition);

            PositionWhenReady = Spawners[StartIndex].ActorLocation + PositionModefire1;
            PositionWhenDone = Spawners[StartIndex].ActorLocation + PositionModefire2+FVector(0,0,1);
            AttackTemplete = Template;
            CurrentHandAttack = HandAttackDirection;

            for(int i = StartIndex-IndexExtentNegative; i <= StartIndex-1; i++){
                 SlamAttackSpawners.Add(Spawners[i]);
            }
            for(int i = StartIndex; i <= IndexExtentPositive + StartIndex; i++){
                 SlamAttackSpawners.Add(Spawners[i]);
            }
           
            FollowPatternBetweenSpawners = FollowPatternBetweenSpawnersInput;
            HandAttacking = true;
            MoveHand = true;
            SlamAttack = true;
    }
    UFUNCTION()
    void MoveJesterHands(){  
        if(PositionalQueue.Num() <= 0){
                
                return;
        }     
        if(ActorLocation.Distance(PositionalQueue[0]) < 10){
            if(PositionWhenReady == PositionalQueue[0]){
                InAttackPosition = true;
            }
            if(PositionWhenDone == PositionalQueue[0]){
                 InAttackPosition = false;
            }
               
            SetActorLocation(PositionalQueue[0]);
            PositionalQueue.RemoveAt(0);
            MoveHand = false;
            if(PositionalQueue.Num() <= 0){
                CurrentlyAttacking = false;
                ResetNumbersBetweenAttacks();
                return;
            }else{
                //add in delay
                System::SetTimer(this,n"ContinueMovingHand",DelayBetweenMovements,false,false);
            }
                
        }
        FVector DirectionToDesired = PositionalQueue[0] - ActorLocation;
        DirectionToDesired.Normalize();
        //System::DrawDebugArrow(LeftHand.WorldLocation,LeftHand.WorldLocation + DirectionToDesired,4,FLinearColor::Red, 10000, 10 );
        SetActorLocation(ActorLocation + DirectionToDesired * HandSpeed);
    }

    UFUNCTION()
    void SlamAttackExecution(){
        SlamDown = true;
    }

    UFUNCTION()
    void ContinueMovingHand(){
        MoveHand = true;
    }

    UFUNCTION()
    void TriggerSpeciicSpawners(TArray<ABulletSpawner> Spawners){
        int i = 0;
        FBulletWaveTemplate Template;
        for(auto Spawner : Spawners){
            if(FollowPatternBetweenSpawners){
                AttackTemplete.BulletType = AttackTemplete.DimensionPattern[i];

                Spawner.SpawnBulletWave(AttackTemplete);
                i++;
                if(i >= AttackTemplete.DimensionPattern.Num()){
                    i = 0;
                }
                    
            }else{
                Spawner.SpawnBulletWave(AttackTemplete);
            }
        }
    }
    UFUNCTION()
    void ResetNumbersBetweenAttacks(){
        
        FollowPatternBetweenSpawners = false;
        SlamAttack = false;
        SlamAttackSpawners.Empty();    
        
        
    }

    UFUNCTION()
    void SetupSlamAttack(){
        if(!SlamDown){
            TotalUnitsDown = 500;
            FVector DirectionToDesired =  Player.ActorLocation + FVector(0,0,500) - ActorLocation;
            DirectionToDesired.Normalize();
            HandSpeed = 10;
            SetActorLocation(ActorLocation + DirectionToDesired * HandSpeed);
        }else{
            SetActorLocation(ActorLocation -FVector(0,0,1)*15);
            TotalUnitsDown -= 15;
            if(TotalUnitsDown <= 0){
                CurrentHandAttack= "";
                PositionalQueue.Add(HandDefaultPosition);
                HandSpeed = 10+ 5*PhaseOfBoss;
                MoveJesterHands();
            }
            
        }
        
    }
}


