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
    UStaticMeshComponent DreamJesterBody;
    UPROPERTY(DefaultComponent)
    UHealComponent Health;

    FAttack Left;
    FAttack Right;
    FAttack Up;
    FAttack Down;
    FAttack Slam;
    FAttack Cross;
    FAttack Omega;

    UPROPERTY()
    AJesterHand JesterHandLeft;
    UPROPERTY()
    AJesterHand JesterHandRight;

    UPROPERTY(DefaultComponent)
    UAudioComponent Audio;

    FVector RightHandDefaultPosition = FVector(0.000005,-440.000000,2410.000000);
    FVector LeftHandDefaultPosition = FVector(0.000006,460.000000,2410.000000);

    TArray<FAttack> Attacks;
    //contains a randomised index of all the attacks used for selection
    TArray<int> AttackOrder;

    //add all attack patterns into there own arrays so they can be triggered seperatly
    
    TArray<ABulletSpawner> TopSpawners;
    TArray<ABulletSpawner> BottomSpawners;
    TArray<ABulletSpawner> LeftSpawners;
    TArray<ABulletSpawner> RightSpawners;
    TArray<ABulletSpawner> CrossSpawners;
    TArray<ABulletSpawner> OmegaSpawners;
    UPROPERTY()
    AActor JesterDown;
    UPROPERTY()
    AActor JesterUp;
    UPROPERTY()
    AActor JesterLeft;
    UPROPERTY()
    AActor JesterRight;

    float GlobalBulletSpeed = 10;

    UPROPERTY()
    FBulletWaveTemplate TopSlamTemplate();
    UPROPERTY()
    FBulletWaveTemplate BottomSlamTemplate();
    UPROPERTY()
    FBulletWaveTemplate OmegaTemplate();

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
        Right.Weight = 18.0f;
        Left.AttackName = "Left";
        Left.Weight = 16.0f;

        Up.AttackName = "Up";
        Up.Weight = 16.0f;

        Down.AttackName = "Down";
        Down.Weight = 17.0f;

        Slam.AttackName = "Slam";
        Slam.Weight = 16.0f;

        Cross.AttackName = "Cross";
        Cross.Weight = 16.0f;

        Omega.AttackName = "Omega";
        Cross.Weight = 1.0f;
        

        Health.SetHealth(150);

        Attacks.Add(Left);
        Attacks.Add(Right);
        Attacks.Add(Up);
        Attacks.Add(Down);
        Attacks.Add(Slam);
        Attacks.Add(Cross);
        Attacks.Add(Omega);

        //base attack order
        AttackOrder.Add(0);
        AttackOrder.Add(1);
        AttackOrder.Add(2);
        AttackOrder.Add(3);
        AttackOrder.Add(4);
        AttackOrder.Add(5);
        AttackOrder.Add(6);
        //finding spawners and its locations
        

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
            }else if(Spawner.GetActorNameOrLabel().Contains("Omega")){
                OmegaSpawners.Add(Spawner);
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
        Audio.Play(140);

        
        JesterHandRight.HandDefaultPosition.Y *=-1;
        JesterHandLeft.SetActorLocation(JesterHandLeft.HandDefaultPosition);
        JesterHandRight.SetActorLocation(JesterHandRight.HandDefaultPosition);
        //OmegaAttack();

        
        DreamJesterBody.SetWorldScale3D(JesterBody.GetWorldScale()/8);
        FRotator Rotation;
        Rotation.Yaw = 0;
        DreamJesterBody.SetWorldRotation(Rotation);
        JesterBody.SetVisibility(false);

        JesterHandLeft.SwapMesh(EDimension::Dream, "Left");
        JesterHandRight.SwapMesh(EDimension::Dream, "Right");
    }


    UFUNCTION()
    void SortSpawner(){
        //this is the easiest way to make sure all the spawners are in the right order, really ugly and i hate it
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

        TArray<ABulletSpawner> tempOmega;
        
       

        //Spawners.Empty();
        int CurrentIndexOmega = 1;
        for(int i = 0; i<OmegaSpawners.Num();i++){
            for(int j = 0; j<OmegaSpawners.Num();j++){
                FString Left;
                FString Right;
                OmegaSpawners[j].GetActorNameOrLabel().Split("_",Left,Right);
                int Value = String::Conv_StringToInt(Right);
                if(Value == CurrentIndexOmega){
                    tempOmega.Add(OmegaSpawners[j]);
                    CurrentIndexOmega++;
                    break;
                }
            }
        }

        OmegaSpawners = tempOmega;

        
    }

    UFUNCTION()
    void DecideAttack(){
        

        if(!JesterHandLeft.CurrentlyAttacking && !JesterHandRight.CurrentlyAttacking){
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
            if(JesterHandRight.CurrentlyAttacking && Attacks[AttackIndex].AttackName == "Right"){
                DecideAttack();
                return;
            }

            if(JesterHandLeft.CurrentlyAttacking && Attacks[AttackIndex].AttackName == "Left"){
                DecideAttack();
                return;
            }
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
            }else if(Attacks[AttackIndex].AttackName == "Omega"){
                OmegaAttack();
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
        
        if(!Audio.IsPlaying()){            
            Audio.Play(0);
        }

    }



    void LeftScreenAttack(){
        //takes left hand and activates the spawners with a downward motion: shoots one bullet
        //need to fix a static version like the slam from the top
        JesterHandLeft.AttackTemplete.BulletDirection = EMovementDirection::Right;
        JesterHandLeft.AttackTemplete.BulletSpeed = GlobalBulletSpeed;
        JesterHandLeft.AttackTemplete.DimensionPattern.Add(EDimension::Dream);
        JesterHandLeft.AttackTemplete.DimensionPattern.Add(EDimension::Dream);
        JesterHandLeft.AttackTemplete.DimensionPattern.Add(EDimension::Nightmare);
        JesterHandLeft.AttackTemplete.DimensionPattern.Add(EDimension::Nightmare);
        JesterHandLeft.AttackTemplete.DimensionPattern.Add(EDimension::Normal);
        JesterHandLeft.AttackTemplete.EnablePattern = true;
        JesterHandLeft.AttackTemplete.RepeatPattern = true;

        JesterHandLeft.PositionWhenReady = LeftSpawners[0].ActorLocation + FVector(0,100,300);
        JesterHandLeft.PositionWhenDone = LeftSpawners.Last().ActorLocation + FVector(0,100,-100);

        JesterHandLeft.PositionalQueue.Add(LeftSpawners[0].ActorLocation + FVector(0,100,300));
        JesterHandLeft.PositionalQueue.Add(LeftSpawners.Last().ActorLocation + FVector(0,100,-100));
        JesterHandLeft.PositionalQueue.Add(JesterHandLeft.HandDefaultPosition);

        JesterHandLeft.HandAttacking = true;
        JesterHandLeft.CurrentHandAttack = "Left";
        JesterHandLeft.MoveHand = true;
        SetActorLocation(JesterLeft.ActorLocation);
        JesterHandLeft.CurrentlyAttacking = true;
        
    }

    void RightScreenAttack(){   
        //same as left but from the right

        JesterHandRight.AttackTemplete.BulletDirection = EMovementDirection::Left;
        JesterHandRight.AttackTemplete.BulletSpeed = GlobalBulletSpeed;
        JesterHandRight.AttackTemplete.DimensionPattern.Add(EDimension::Dream);
        JesterHandRight.AttackTemplete.DimensionPattern.Add(EDimension::Dream);
        JesterHandRight.AttackTemplete.DimensionPattern.Add(EDimension::Nightmare);
        JesterHandRight.AttackTemplete.DimensionPattern.Add(EDimension::Nightmare);
        JesterHandRight.AttackTemplete.DimensionPattern.Add(EDimension::Normal);
        JesterHandRight.AttackTemplete.EnablePattern = true;
        JesterHandRight.AttackTemplete.RepeatPattern = true;
        JesterHandRight.PositionWhenDone = RightSpawners[0].ActorLocation + FVector(0,-100,300);
        JesterHandRight.PositionWhenReady = RightSpawners.Last().ActorLocation + FVector(0,-100,-100);
        JesterHandRight.PositionalQueue.Add(RightSpawners.Last().ActorLocation + FVector(0,-100,-100));
        JesterHandRight.PositionalQueue.Add(RightSpawners[0].ActorLocation + FVector(0,-100,300));
        JesterHandRight.PositionalQueue.Add(JesterHandRight.HandDefaultPosition);
        JesterHandRight.HandAttacking = true;
        JesterHandRight.CurrentHandAttack = "Right";
        JesterHandRight.MoveHand = true;
        SetActorLocation(JesterRight.ActorLocation);
        JesterHandRight.CurrentlyAttacking = true;
        
    }

    void UpScreenAttack(){
        //lams the top if the map and send bullets down 50:50 which side
        //really really stupid and hardcoded
        float Side = Math::RandRange(0.0f, 100.0f);
        if(Side < 50.0f){
            JesterHandLeft.HandSlamAttack(TopSpawners,2,2,2,"Up",TopSlamTemplate,true,FVector(0,0,600),FVector(0,0,0),4);
            JesterHandLeft.CurrentlyAttacking = true;
        }else{
            JesterHandRight.HandSlamAttack(TopSpawners,7,2,2,"Up",TopSlamTemplate,true,FVector(0,0,600),FVector(0,0,0),4);
            JesterHandRight.CurrentlyAttacking = true;
        }
        

        SetActorLocation(JesterUp.ActorLocation);

    }

    void DownScreenAttack(){
        //same as up but defies gravity
        float Side = Math::RandRange(0.0f, 90.0f);
        if(Side < 30.0f){
            JesterHandLeft.HandSlamAttack(BottomSpawners,0,1,0,"Down",BottomSlamTemplate,true,FVector(0,0,-600),FVector(0,0,0),4);
            JesterHandLeft.CurrentlyAttacking = true;
        }else if(Side < 60.0f){
            float WhichHand = Math::RandRange(0.0f, 100.0f);
            if(WhichHand < 50.0f){
                 JesterHandLeft.HandSlamAttack(BottomSpawners,3,2,1,"Down",BottomSlamTemplate,true,FVector(0,0,-600),FVector(0,0,0),4);
                 JesterHandLeft.CurrentlyAttacking = true;
            }else{
                JesterHandRight.HandSlamAttack(BottomSpawners,3,2,1,"Down",BottomSlamTemplate,true,FVector(0,0,-600),FVector(0,0,0),4);
                JesterHandRight.CurrentlyAttacking = true;
            }
        }else{
            JesterHandRight.HandSlamAttack(BottomSpawners,6,1,0,"Down",BottomSlamTemplate,true,FVector(0,0,-600),FVector(0,0,0),4);
            JesterHandRight.CurrentlyAttacking = true;
        }
        SetActorLocation(JesterUp.ActorLocation);
        
    }

    void CrossAttack(){
        //swipes hand throught the cross and triggers them
        JesterHandLeft.PositionWhenReady = CrossSpawners[27].ActorLocation + FVector(0,300,300);
        JesterHandLeft.PositionWhenDone = CrossSpawners[13].ActorLocation - FVector(0,300,300);

        JesterHandLeft.PositionalQueue.Add(CrossSpawners[27].ActorLocation + FVector(0,300,300));
        JesterHandLeft.PositionalQueue.Add(CrossSpawners[13].ActorLocation - FVector(0,300,300));
        JesterHandLeft.PositionalQueue.Add(JesterHandLeft.HandDefaultPosition);

        JesterHandLeft.HandAttacking = true;
        JesterHandLeft.CurrentHandAttack = "Cross";
        JesterHandLeft.MoveHand = true;
        


        JesterHandRight.PositionWhenReady = CrossSpawners[41].ActorLocation + FVector(0,-300,300);
        JesterHandRight.PositionWhenDone = CrossSpawners[42].ActorLocation - FVector(0,-300,300);

        JesterHandRight.PositionalQueue.Add(CrossSpawners[41].ActorLocation + FVector(0,-300,300));
        JesterHandRight.PositionalQueue.Add(CrossSpawners[42].ActorLocation - FVector(0,-300,300));
        JesterHandRight.PositionalQueue.Add(JesterHandRight.HandDefaultPosition);

        JesterHandRight.HandAttacking = true;
        JesterHandRight.CurrentHandAttack = "Cross";
        JesterHandRight.MoveHand = true;

        SetActorLocation(JesterDown.ActorLocation);

        JesterHandLeft.CurrentlyAttacking = true;
        JesterHandRight.CurrentlyAttacking = true;
       
    }

    void SlamAttack(){
        //slams where the player is

        float WhichHand = Math::RandRange(0.0f,100.0f);
        
        if(WhichHand < 50.0f){
            JesterHandLeft.HandAttacking = true;
            JesterHandLeft.CurrentHandAttack = "Slam";
            JesterHandLeft.MoveHand = true;
            JesterHandLeft.CurrentlyAttacking = true;
            System::SetTimer(JesterHandLeft,n"SlamAttackExecution",3,false,false);
        }else{
            JesterHandRight.HandAttacking = true;
            JesterHandRight.CurrentHandAttack = "Slam";
            JesterHandRight.MoveHand = true;
            JesterHandRight.CurrentlyAttacking = true;


            System::SetTimer(JesterHandRight,n"SlamAttackExecution",3,false,false);
        }
        SetActorLocation(JesterUp.ActorLocation);
        
    }

    void OmegaAttack(){
        JesterHandLeft.PositionWhenReady =  OmegaSpawners[0].ActorLocation;
        JesterHandLeft.PositionWhenReady =  OmegaSpawners[0].ActorLocation-FVector(0,1,0);

        JesterHandLeft.PositionalQueue.Add(OmegaSpawners[0].ActorLocation);
        JesterHandLeft.PositionalQueue.Add(OmegaSpawners.Last().ActorLocation);
        JesterHandLeft.PositionalQueue.Add(OmegaSpawners[0].ActorLocation);
        JesterHandLeft.PositionalQueue.Add(OmegaSpawners.Last().ActorLocation);
        JesterHandLeft.PositionalQueue.Add(OmegaSpawners[0].ActorLocation-FVector(0,1,0));
        JesterHandLeft.PositionalQueue.Add(JesterHandRight.HandDefaultPosition);

        JesterHandLeft.HandAttacking = true;
        JesterHandLeft.CurrentHandAttack = "Omega";
        JesterHandLeft.MoveHand = true;
        JesterHandLeft.CurrentlyAttacking = true;
        

        JesterHandRight.PositionWhenReady =  OmegaSpawners.Last().ActorLocation;
        JesterHandRight.PositionWhenReady =  OmegaSpawners.Last().ActorLocation+FVector(0,1,0);

        JesterHandRight.PositionalQueue.Add(OmegaSpawners.Last().ActorLocation);
        JesterHandRight.PositionalQueue.Add(OmegaSpawners[0].ActorLocation);
        JesterHandRight.PositionalQueue.Add(OmegaSpawners.Last().ActorLocation);
        JesterHandRight.PositionalQueue.Add(OmegaSpawners[0].ActorLocation);
        JesterHandRight.PositionalQueue.Add(OmegaSpawners.Last().ActorLocation+FVector(0,1,0));
        JesterHandRight.PositionalQueue.Add(JesterHandRight.HandDefaultPosition);

        JesterHandRight.HandAttacking = true;
        JesterHandRight.CurrentHandAttack = "Omega";
        JesterHandRight.MoveHand = true;
        JesterHandRight.CurrentlyAttacking = true;

        System::SetTimer(this, n"TriggerOmegaSpawners", 0.4,false,false);
    }
    UFUNCTION()
    void TriggerOmegaSpawners(){
        OmegaTemplate.BulletSpeed = GlobalBulletSpeed;
        for(auto OSP : OmegaSpawners){
            OSP.SpawnBulletWave(OmegaTemplate);
        }
    }


    UFUNCTION()
    void TakeDamage(int amount){
        Health.DecreaseHealth(amount);
        if(Health.CurrentHealth <= Health.MaxHealth-Health.MaxHealth /3.0f && FirstTimeUnder60){
            //phase 2
            FirstTimeUnder60 = false;
            PhaseOfBoss = 2;
            GlobalBulletSpeed = 10+5*PhaseOfBoss;
            
            TopSlamTemplate.BulletSpeed = GlobalBulletSpeed;
            BottomSlamTemplate.BulletSpeed = GlobalBulletSpeed;
            Audio.Stop();
            float StopTime = Audio.Sound.Duration*PlayBackDuration;
            Audio.Sound =GameManager.NightmareMusic[PhaseOfBoss-1];
            Audio.Play(StopTime);

        }
        if(Health.CurrentHealth <= Health.MaxHealth /3.0f && FirstTimeUnder30){
            FirstTimeUnder30 = false;
            PhaseOfBoss = 3;
            GlobalBulletSpeed = 10+5*PhaseOfBoss;
            Audio.Stop();
            float StopTime = Audio.Sound.Duration*PlayBackDuration;
            Audio.Sound =GameManager.NightmareMusic[PhaseOfBoss-1];
            Audio.Play(StopTime);
        }

        JesterHandRight.PhaseOfBoss = PhaseOfBoss;
        JesterHandRight.GlobalBulletSpeed = GlobalBulletSpeed;

        JesterHandLeft.PhaseOfBoss = PhaseOfBoss;
        JesterHandLeft.GlobalBulletSpeed = GlobalBulletSpeed;
        if(Health.CurrentHealth <= 0){
            GameManager.BossDied();
        }
       
    }

    UFUNCTION()
    void SwapDimensions(EDimension NewDimension){
        if(NewDimension == EDimension::Dream){
            Audio.Stop();
            float StopTime = Audio.Sound.Duration*PlayBackDuration;
            Audio.Sound = GameManager.DreamMusic[PhaseOfBoss-1];
            Audio.Play(StopTime);

  
            DreamJesterBody.SetVisibility(true);
            JesterBody.SetVisibility(false);

            JesterHandLeft.SwapMesh(NewDimension,"Left");
            JesterHandRight.SwapMesh(NewDimension,"Right");

        }else if(NewDimension == EDimension::Nightmare){
            Audio.Stop();
            float StopTime = Audio.Sound.Duration *PlayBackDuration;
            Audio.Sound = GameManager.NightmareMusic[PhaseOfBoss-1];
            Audio.Play(StopTime);
  
            DreamJesterBody.SetVisibility(false);
            JesterBody.SetVisibility(true);

            JesterHandLeft.SwapMesh(NewDimension,"Left");
            JesterHandRight.SwapMesh(NewDimension,"Right");
        }
    }

}