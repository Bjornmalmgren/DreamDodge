struct FBulletWaveTemplate{
    //what dimension should the bullet be in
    UPROPERTY()
    EDimension BulletType = EDimension::Normal;
    //how many bullets should be fired, cant be negative
    UPROPERTY()
    int HowManyBullets = 1;
    //speed of the bullet
    UPROPERTY()
    float BulletSpeed = 5;
    //direction of bullets, only supports the cardianl and diagonals shown
    UPROPERTY()
    EMovementDirection BulletDirection =EMovementDirection::Left;
    //delay between bullets, cant be negative
    UPROPERTY()
    float Delay = 0.1;
    //should the bullets change mid wave
    UPROPERTY()
    bool MultipleBulletTypes = false;
    //should it only be next bullet or the rest of the wave
    UPROPERTY()
    bool RestOfWave = false;
    //only applicable if MultipleBulletTypes is true
    UPROPERTY()
    EDimension OtherBulletType;
    //from which bullet in wave should the new type be applied if RestOfWave is true other wise on next one, cant be negative
    UPROPERTY()
    int FromWhichBullet = 0;
    //Enable this if you want to manualy input a pattern that overides the bullet types
    UPROPERTY()
    bool EnablePattern = false;
    //the pattern you want to use, can either be hand crafted in its entierty or craft a section to repeat
    UPROPERTY()
    TArray<EDimension> DimensionPattern;
    //enable this to repeat pattern for all bullets
    UPROPERTY()
    bool RepeatPattern = false;

}

//to set the direction of the bullet rotate the spawner so the front points towards where the bullets come from
class ABulletSpawner : AActor{
    UPROPERTY(DefaultComponent)
    USceneComponent Root;

    UPROPERTY()
    TSubclassOf<ABullet> BulletRef;

    UPROPERTY()
    FBulletWaveTemplate BulletWave;
    int BulletCount = 0;
    FRotator BulletRotation;
    bool SpecialBullets = true;
    bool PatternComplete = false;
    int CurrentPatternIndex = 0;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
    }

    UFUNCTION()
    void SpawnBulletWave(FBulletWaveTemplate WaveTemplate){
        BulletWave = WaveTemplate;
        BulletCount = 0;
        SpecialBullets = true;
        switch(BulletWave.BulletDirection){
            case EMovementDirection::Up:
                    BulletRotation.Roll = 90;
                break;
                case EMovementDirection::Down:
                    BulletRotation.Roll = -90;
                break;
                case EMovementDirection::Left:
                    //default
                break;
                case EMovementDirection::Right:
                    BulletRotation.Roll = 180;
                break;
                case EMovementDirection::UpLeft:
                    BulletRotation.Roll = 315;
                break;
                case EMovementDirection::UpRight:
                    BulletRotation.Roll = 225;
                break;
                case EMovementDirection::DownLeft:
                    BulletRotation.Roll = 45;
                break;
                case EMovementDirection::DownRight:
                    BulletRotation.Roll = 135;
                break;
        }
        //add timer
        System::SetTimer(this,n"SpawnBullet",BulletWave.Delay,true,true);
    }
    UFUNCTION()
    void SpawnBullet(){
        
        if(BulletCount < BulletWave.HowManyBullets){
            if((BulletWave.MultipleBulletTypes && BulletWave.FromWhichBullet <= BulletCount && SpecialBullets) ||( BulletWave.EnablePattern && !PatternComplete)){
                if(BulletWave.EnablePattern && !PatternComplete){
                    ABullet Spawnedbullet = SpawnActor(BulletRef,ActorLocation,BulletRotation);
                    Spawnedbullet.SetUpBullet(BulletWave.BulletDirection,BulletWave.DimensionPattern[CurrentPatternIndex],EAttackType::Normal,BulletWave.BulletSpeed,true);
                    CurrentPatternIndex++;
                    
                    if(CurrentPatternIndex >= BulletWave.DimensionPattern.Num() && BulletWave.RepeatPattern){
                        CurrentPatternIndex = 0;
                    }else if(CurrentPatternIndex >= BulletWave.DimensionPattern.Num()){
                        PatternComplete = true;
                    }
                }
                else if(BulletWave.RestOfWave){
                    //rest of wave
                    ABullet Spawnedbullet = SpawnActor(BulletRef,ActorLocation,BulletRotation);
                    Spawnedbullet.SetUpBullet(BulletWave.BulletDirection,BulletWave.OtherBulletType,EAttackType::Normal,BulletWave.BulletSpeed,true);
                }else{
                    //only next
                    ABullet Spawnedbullet = SpawnActor(BulletRef,ActorLocation,BulletRotation);
                    Spawnedbullet.SetUpBullet(BulletWave.BulletDirection,BulletWave.OtherBulletType,EAttackType::Normal,BulletWave.BulletSpeed,true);
                    SpecialBullets = false;
                }
            }else{
                ABullet Spawnedbullet = SpawnActor(BulletRef,ActorLocation,BulletRotation);
                Spawnedbullet.SetUpBullet(BulletWave.BulletDirection,BulletWave.BulletType,EAttackType::Normal,BulletWave.BulletSpeed,true);
            }
            
            BulletCount++;
        }else{
            
            System::ClearTimer(this, "SpawnBullet");
            CurrentPatternIndex = 0;
        }
        
    }
}