

class AWeapon : AActor{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;
    UPROPERTY(DefaultComponent)
    UStaticMeshComponent Mesh;

    int MaxExtend = 600;
    int ExtensionAmount = 600;
    int CurrentExtension = 0;

    APlayer Player;

    FVector DirectionFromPlayer;
    FVector CalculatedPosition;
    bool AttackInProgress = false;

    //timers
    FTimerHandle ExtensionTimer;

    UPROPERTY()
    TSubclassOf<ABeamHitBox> BeamRefrence;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        TArray<APlayer> Players;
        GetAllActorsOfClass(APlayer,Players);
        Player = Players[0];
    }
    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        //make rotate correctly around the player and stop when attacking at the correct place maybe?
        if(!AttackInProgress){
            APlayerController PC = Cast<APlayerController>(Player.GetController());
            FVector Position;
            FVector Direction;
            PC.DeprojectMousePositionToWorld(Position, Direction);
            FVector Normal = FVector(1,0,0);
            FVector Point0 = FVector(0,0,0);
            float Denom = Normal.DotProduct(Direction);
            float T = (Point0-Position).DotProduct(Normal);
            if(Denom == 0){
                SetActorLocation(Player.ActorLocation + FVector(0,200,0));
                return;
            }
            T /= Denom;
            CalculatedPosition = Position + Direction*T;
            CalculatedPosition.Z = Player.ActorLocation.Z;
            if(CalculatedPosition.Y > Player.ActorLocation.Y){
                SetActorLocation(Player.ActorLocation + FVector(0,200,0));
            }else if(CalculatedPosition.Y < Player.ActorLocation.Y){
                SetActorLocation(Player.ActorLocation - FVector(0,200,0));
            }
                
        }
            
    }


    //creates the damage area and moves the weapon for the attack
    UFUNCTION()
    void BeamAttack(){
        if(AttackInProgress){
            return;
        }
        AttackInProgress = true;
        //gets the deproject mouse position and direction
        APlayerController PC = Cast<APlayerController>(Player.GetController());
        DirectionFromPlayer = CalculatedPosition-Player.ActorLocation;
        DirectionFromPlayer.Normalize();
        
        
        float Radians = Mesh.WorldLocation.AngularDistance(CalculatedPosition);
        float Degrees = Math::RadiansToDegrees(Radians);
        
        FRotator Roation = Mesh.GetWorldRotation();
        Roation.Roll = Degrees;
        Mesh.SetWorldRotation(Roation);

        ABeamHitBox HitBox = SpawnActor(BeamRefrence,FVector(0,0,-1000),FRotator::ZeroRotator);
        HitBox.SetActorLocation(Mesh.WorldLocation +DirectionFromPlayer * HitBox.HitBox.BoxExtent.Y);

        //total time to extend
        System::SetTimer(this,n"StartRetracting",0.11,false,true);
        //time between extensions
        ExtensionTimer = System::SetTimer(this,n"Extend",0.1,true,true);
        System::SetTimer(HitBox,n"Destroy",0.22,false,false);

    }
    UFUNCTION()
    void Extend(){
        //rotate the mesh around the x axel towards where the click happend and move it along that path
        if(CurrentExtension >= MaxExtend){
            return;
        }
        Mesh.SetWorldLocation(Mesh.GetWorldLocation()+ DirectionFromPlayer * ExtensionAmount);
        CurrentExtension += ExtensionAmount;
    }
    UFUNCTION()
    void StartRetracting(){
        System::ClearTimer(this,"Extend");
        ExtensionTimer = System::SetTimer(this,n"Retract",0.1,true,true);
        System::SetTimer(this,n"ClearAttack",0.11,false,true);
    }

    UFUNCTION()
    void Retract(){
        if(CurrentExtension <= 0){
            return;
        }
        Mesh.SetWorldLocation(Mesh.GetWorldLocation()+ DirectionFromPlayer * -ExtensionAmount);
        CurrentExtension -= ExtensionAmount;

    }
    UFUNCTION()
    void ClearAttack(){
        System::ClearTimer(this,"Retract");
        AttackInProgress = false;
    }
}