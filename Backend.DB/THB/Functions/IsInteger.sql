
CREATE FUNCTION THB.IsInteger(@Value varchar(30))
Returns Bit
As 
Begin
  
  Return ISNULL(
     (Select Case When CharIndex('.', @Value) > 0 
                  Then Case When Convert(int, ParseName(@Value, 1)) <> 0
                            Then 0
                            Else 1
                            End
                  Else 1
                  End
      Where IsNumeric(@Value + 'e0') = 1), 0)

End