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
    UEndScreenWidget EndScreen;

    UPROPERTY()
    float DodgeMeter = 0;

    AWeapon DreamCatcher;

    AGameManager GameManager;

    AEnviormentManager EnviormentManager;

    bool Invincibility = false;

    UPROPERTY()
    bool StartedHealing = false;
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {    
        Setup();
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        if(ActorLocation.X != 0){
            FVector Position = GetActorLocation();
            Position.X = 0;
            SetActorLocation(Position);
        }
    }


    UFUNCTION()
    void Setup(){
        HealthComponent.SetHealth(5);
        ChangeMeter();
        TArray<AGameManager> GameManagers;
        GetAllActorsOfClass(AGameManager,GameManagers);
        GameManager = GameManagers[0];

        TArray<AEnviormentManager> EnviormentManagers;
        GetAllActorsOfClass(AEnviormentManager,EnviormentManagers);
        EnviormentManager = EnviormentManagers[0];


        TArray<AWeapon> Weapons;
        GetAllActorsOfClass(AWeapon, Weapons);
        DreamCatcher = Weapons[0];

        EndScreen.Restart.OnPressed.AddUFunction(this, n"ResetLevel");        

        Cast<APlayerController>(GetController()).bShowMouseCursor = true;
    }

    void ChangeMeter(){
        float ProcentPerHealth = 100.0f/HealthComponent.MaxHealth;
        
        HUD.HealthMeter.SetPercent(ProcentPerHealth/100.0f * HealthComponent.CurrentHealth);
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
        if(OtherActor.ActorHasTag(n"Bullet") && !Invincibility){
            if(Cast<ABullet>(OtherActor).BulletType != CurrentDimension){
                HealthComponent.DecreaseHealth(1);
                ChangeMeter();
                Invincibility = true;
                System::SetTimer(this,n"OutOfinvincibility",0.4f,false,false);
                if(HealthComponent.CurrentHealth <= 0){
                    //die and reset lvl
                    GameManager.PlayerDied();
                }
            }else{
                DodgeMeter += 10;
                ChangeMeter();
            }
        }
    }

    UFUNCTION()
    void OutOfinvincibility(){
        Invincibility = false;
    }

    //heal or attack
    UFUNCTION()
    void UseDodgeMeterValue(float ElapsedTime){
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
            if(DodgeMeter >= 20){
                Attack();
                DodgeMeter -=20;
            }
        }
        ChangeMeter();
    }

    //beam attack
    void Attack(){
        DreamCatcher.BeamAttack();
    }

    //jump
    UFUNCTION()
    void JumpInput(){
        if(!StartedHealing)
            Jump();
    }

    //main function of game swaping between dimensions needs some more work like changing enviorment and similar
    UFUNCTION()
    void SwapDimensions(){
        if(StartedHealing){
            return;
        }
        DynamicMaterial = CharacterMesh.CreateDynamicMaterialInstance(0);
        if(CurrentDimension == EDimension::Dream){
            CurrentDimension = EDimension::Nightmare;
            DynamicMaterial.SetVectorParameterValue(n"Color", GameManager.Nightmare);
        }
        else if(CurrentDimension == EDimension::Nightmare){
            CurrentDimension = EDimension::Dream;
            DynamicMaterial.SetVectorParameterValue(n"Color", GameManager.Dream);
        }
        GameManager.SwapDimensions(CurrentDimension);
        
    }

    UFUNCTION()
    void ResetLevel(){
        Gameplay::OpenLevel(GetWorld().GetName());
    }

    
}