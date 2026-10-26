
enum EMovementDirection{
    Up,
    Down,
    Left,
    Right
}

enum EBulletType{
    Dream,
    Nightmare,
    Normal
}

enum EAttackType{
    Normal
}
class ABullet : AActor{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;
    UPROPERTY(DefaultComponent, Attach = Root)
    UStaticMeshComponent Mesh;
    UPROPERTY(DefaultComponent)
    UBoxComponent BoxOverlap;

    UPROPERTY()
    bool StartMoving = true;
    UPROPERTY()
    float Speed = 5;
    UPROPERTY()
    EMovementDirection DirectionToMoveIn = EMovementDirection::Left;
    UPROPERTY()
    EBulletType BulletType = EBulletType::Normal;
    UPROPERTY()
    EAttackType TypeOfAttack = EAttackType::Normal;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Tags.Add(n"Bullet");
    }
    
    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        if(StartMoving){
            switch(DirectionToMoveIn){
                case EMovementDirection::Up:
                    SetActorLocation(GetActorLocation() + FVector(0,0,1)*Speed);
                break;
                case EMovementDirection::Down:
                    SetActorLocation(GetActorLocation() + FVector(0,0,-1)*Speed);
                break;
                case EMovementDirection::Left:
                    SetActorLocation(GetActorLocation() + FVector(0,1,0)*Speed);
                break;
                case EMovementDirection::Right:
                    SetActorLocation(GetActorLocation() + FVector(0,-1,0)*Speed);
                break;
            }
        }
    }

    UFUNCTION(BlueprintOverride)
    void ActorBeginOverlap(AActor OtherActor)
    {
        if(OtherActor.ActorHasTag(n"Player")){
            //damage player
            Destroy();
        }
    }

    UFUNCTION()
    void StartDestructionTimer(){
        System::SetTimer(this, n"Destroy",10,false,false);
    }

    UFUNCTION()
    void Destroy(){
        DestroyActor();
    }
}