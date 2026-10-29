class AEnviormentManager : AActor{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;
    
    TArray<APlatform> DreamPlatforms;
    TArray<APlatform> NightmarePlatforms;

    AGameManager GameManager;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        TArray<AGameManager> GameManagers;
        GetAllActorsOfClass(AGameManager,GameManagers);
        GameManager = GameManagers[0];

        TArray<APlatform> AllPlatforms;
        GetAllActorsOfClass(APlatform, AllPlatforms);

        for(auto Platform : AllPlatforms){
            if(Platform.ExistingDimension == EDimension::Dream){
                Platform.SetColor(GameManager.Dream);
                DreamPlatforms.Add(Platform);
                
            }
            if(Platform.ExistingDimension == EDimension::Nightmare){
                Platform.SetColor(GameManager.Nightmare);
                NightmarePlatforms.Add(Platform);
            }
            if(Platform.ExistingDimension == EDimension::Normal){
                Platform.ExistingDimension = EDimension::Dream;
                Platform.SetColor(GameManager.Dream);
                DreamPlatforms.Add(Platform);
                
            }
        }
        HidePlatforms(EDimension::Dream);
       
    }
    UFUNCTION()
    void HidePlatforms(EDimension CurrentDimension){
        if(CurrentDimension == EDimension::Dream){
            for(auto DPlatform :DreamPlatforms){
                DPlatform.SetActorHiddenInGame(false);
                DPlatform.SetActorEnableCollision(true);
            }
            for(auto NPlatform :NightmarePlatforms){
                NPlatform.SetActorHiddenInGame(true);
                NPlatform.SetActorEnableCollision(false);
            }
        }
        if(CurrentDimension == EDimension::Nightmare){
            for(auto DPlatform :DreamPlatforms){
                DPlatform.SetActorHiddenInGame(true);
                DPlatform.SetActorEnableCollision(false);
            }
            for(auto NPlatform :NightmarePlatforms){
                NPlatform.SetActorHiddenInGame(false);
                NPlatform.SetActorEnableCollision(true);
            }
        }
        //anything else and shit is horribly wrong
    }
}