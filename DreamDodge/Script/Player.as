class APlayer : ACharacter{
    UPROPERTY(DefaultComponent)
    UEnhancedInputComponent Input;
    UPROPERTY(DefaultComponent)
    UStaticMeshComponent CharacterMesh;
    UPROPERTY(DefaultComponent)
    UHealComponent HealthComponent;
    
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
       HealthComponent.SetHealth(6);
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {

    }

    UFUNCTION()
    void MoveInput(int direction){
        AddMovementInput(ActorRightVector, direction,false);
    }

    UFUNCTION(BlueprintOverride)
    void ActorBeginOverlap(AActor OtherActor)
    {
        if(OtherActor.ActorHasTag(n"Bullet")){
            HealthComponent.DecreaseHealth(1);
            if(HealthComponent.CurrentHealth <= 0){
                //die and reset lvl
            }
        }
    }

    UFUNCTION()
    void JumpInput(){
        Jump();
    }

    
}