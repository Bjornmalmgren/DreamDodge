UCLASS(Abstract)
class UHeadsUpDisplay : UUserWidget{
    UPROPERTY(BindWidget)
    UProgressBar DodgeMeter;
    UPROPERTY(BindWidget)
    UProgressBar HealthMeter;

}