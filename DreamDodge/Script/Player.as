class APlayer : ACharacter{
    UPROPERTY(DefaultComponent)
    UEnhancedInputComponent Input;
    UPROPERTY(DefaultComponent)
    UStaticMeshComponent CharacterMesh;
    UPROPERTY(DefaultComponent)
    UHealComponent HealthComponent;
    
    UPROPERTY()
    EDimension CurrentDimension = EDimension::Dream;

    UMaterialInstanceDynamic DynamicMaterial;

    UPROPERTY()
    UHeadsUpDisplay HUD;

    UPROPERTY()
    float DodgeMeter = 50;

    UPROPERTY()
    bool StartedHealing = false;
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        HealthComponent.SetHealth(6);
        ChangeMeter();
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {

    }


    void ChangeMeter(){

        HUD.DodgeMeter.SetPercent(DodgeMeter/100);
    }

    UFUNCTION()
    void MoveInput(int direction){
        if(!StartedHealing)
            AddMovementInput(ActorRightVector, direction,false);
    }

    UFUNCTION(BlueprintOverride)
    void ActorBeginOverlap(AActor OtherActor)
    {
        if(OtherActor.ActorHasTag(n"Bullet")){
            if(Cast<ABullet>(OtherActor).BulletType != CurrentDimension){
                HealthComponent.DecreaseHealth(1);
                if(HealthComponent.CurrentHealth <= 0){
                    //die and reset lvl
                }
            }else{
                DodgeMeter += 10;
                Print("DodgeMeter: "+DodgeMeter);
                ChangeMeter();
            }
        }
    }
    //heal or attack
    UFUNCTION()
    void UseDodgeMeterValue(float ElapsedTime){
        Print("DodgeMeter: "+DodgeMeter);
        if(CurrentDimension == EDimension::Dream){
            if(StartedHealing != true && DodgeMeter >= 50){
                StartedHealing = true;
                DodgeMeter -= 5;
            }else{
                if(ElapsedTime >= 1.0){
                    //only heal after one second
                    HealthComponent.IncreaseHealth(1);
                    DodgeMeter -= 45;
                }
                StartedHealing = false;
            }

        }else if (CurrentDimension == EDimension::Nightmare){
            if(DodgeMeter > 20){
                Attack();
            }
        }
        ChangeMeter();
    }

    //beam attack
    void Attack(){
        //spawn an attack area to check if attack hit
    }

    //jump
    UFUNCTION()
    void JumpInput(){
        if(!StartedHealing)
            Jump();
    }

    //main function of game swaping between dimensions
    UFUNCTION()
    void SwapDimensions(){
        if(StartedHealing){
            return;
        }
        DynamicMaterial = CharacterMesh.CreateDynamicMaterialInstance(0);
        if(CurrentDimension == EDimension::Dream){
            CurrentDimension = EDimension::Nightmare;
            DynamicMaterial.SetVectorParameterValue(n"Color", FLinearColor(0.5,0,0,1));
        }
        else if(CurrentDimension == EDimension::Nightmare){
            CurrentDimension = EDimension::Dream;
            DynamicMaterial.SetVectorParameterValue(n"Color", FLinearColor(0.875,0.127,0.568,1));
        }
    }

    
}