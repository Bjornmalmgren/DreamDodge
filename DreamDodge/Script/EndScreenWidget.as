UCLASS(Abstract)
class UEndScreenWidget : UUserWidget{
    UPROPERTY(BindWidget)
    UTextBlock Message;
    UPROPERTY(BindWidget)
    UButton Restart;
}