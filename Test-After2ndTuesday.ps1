<#
.Synopsis
    Checks the entered date to see if it is before or after the 2nd Tuesday of the month entered
    If the date is before, returns $False
    If the date is the same or after, returns $True
    Also verfies that the date entered actually exists for the month entered
.EXAMPLE
    .\Test-After2ndTuesday.ps1 -Date "2023-12-30"
.Author
    Sean Eatch
.Date
    2023-09-11
.Requirements
    -Date entered in format year-month-day
    -Running on a machine with at least Powershell version 5.1
#>

param (
    [Parameter(Mandatory = $True)]
    [string]$Date
)

Try {

    # Split up the numbers by the dashes between them 
    $DateElements = $Date.Split("-")

    # Select the 1st split item, the Year
    $Year = $DateElements[0]

    # Select the 2nd split item, the Month
    $Month = $DateElements[1]

    # Select the 3rd split item, the Day
    $Day = $DateElements[2]

    # Use the built in DateTime method to lookup how many days are in the month entered 
    $DaysInEnteredMonth = [DateTime]::DaysInMonth($Year, $Month)

    # Create a variable to be later expanded in to an array of the number of days in the month entered
    $DaysInMonth = "1.." + $DaysInEnteredMonth

    # Create an array of the number of days in the month entered
    $ArrayDaysInMonth = Invoke-Expression -Command $DaysInMonth

    # Verify the day entered is actually a day in the month entered
    If ($ArrayDaysInMonth -NotContains $Day) {
        $global:LASTEXITCODE = $False
        Write-Host "The day entered, $day, is not a day within the month entered, $Month"
    }

    If ($ArrayDaysInMonth -Contains $Day) {

        # Create a variable of the 1st of the month for the month entered
        [DateTime]$FirstDayOfTheMonth = ( -join ($Month, "/1/", $Year))

        # Create an empty variable that will hold an array of just the Tuesdays in the month entered
        [System.Collections.ArrayList]$TuesdaysThisMonth = [PSCustomObject]@()

        # For every day in the month entered...
        ForEach ($ArrayDay in $ArrayDaysInMonth) {

            # Starting from the first day of the mont entered, add a day
            [DateTime]$DayFinder = $FirstDayOfTheMonth.AddDays($ArrayDay)

            # If the DayOfWeek is Tuesday...
            If ($DayFinder.DayOfWeek -eq "Tuesday") {

                # Add the date found to the empty variable we created earlier (send it to Out-Null so you don't see the output)
                $TuesdaysThisMonth.Add($DayFinder) | Out-Null

            }
    
        }

        # From all the Tuesdays found in the month entered, select the 2nd one
        $2ndTuesday = $TuesdaysThisMonth[1]

        # If the date entered is less then the 2nd Tuesday of the month entered, set the exit code to $False and say False
        If ([DateTime]$Date -lt $2ndTuesday) {
            $global:LASTEXITCODE = $False
            Write-Host "False"
        }

        # If the date entered is greater then the 2nd Tuesday of the month entered, set the exit code to $True and say True
        If ([DateTime]$Date -ge $2ndTuesday) {
            $global:LASTEXITCODE = $True
            Write-Host "True"
        } 

    }
      
}

Catch {

    $ErrorMessage = $_.Exception.Message
    
    Write-Host "The following error occured while trying to run Test-After2ndTuesday: $ErrorMessage"

    $global:LASTEXITCODE = $False
    
}