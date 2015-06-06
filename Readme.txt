                              MORSE RUNNER  1.68

                              Contest Simulator

                                  freeware

               Copyright (C) 2004-2006 Alex Shovkoplyas, VE3NEA

                      http://www.dxatlas.com/MorseRunner/




PLATFORMS

  - Windows 95/98/ME/NT4/2000/XP;
  - works on Linux systems under WINE (info TNX F8BQQ).



INSTALLATION

  - run Setup.exe and follow the on-screen instructions.



UNINSTALLATION

  - click on Add/Remove Programs in the Windows Control Panel;
  - select Morse Runner in the list of installed programs and click on Remove.



CONFIGURATION

  Station

    Call - enter your contest callsign here.

    QSK - simulates the semi-duplex operation of the radio. Enable it if your
      physical radio supports QSK. If it doesn't, enable QSK anyway to see
      what you are missing.

    CW Speed - select the CW speed, in WPM (PARIS system) that matches your
      skills. The calling stations will call you at about the same speed.

    CW Pitch - pitch in Hz.

    RX Bandwidth - the receiver bandwidth, in Hz.

    Audio Recording Enabled - when this menu option is checked, MR saves
      the audio in the MorseRunner.wav file. If this file already
      exists, MR overwrites it.



  Band Conditions

     I tried to make the sound as realistic as possible, and included a few
     effects based on the mathematical model of the ionospheric propagation.
     Also, some of the calling stations exhibit less then perfect operating
     skills, again to make the simulation more realistic. These effects can
     be turned on and off using the checkboxes described below.


     QRM - interference form other running stations occurs from time to time.

     QRN - electrostatic interference.

     QSB - signal strength varies with time (Rayleigh fading channel).

     Flutter - some stations have "auroral" sound.

     LIDS - some stations call you when you are working another station,
       make mistakes when they send code, copy your messages incorrectly,
       and send RST other than 599.

     Activity - band activity, determines how many stations on average
       reply to your CQ.



  Audio buffer size

    You can adjust the audio buffer size by changing the BufSize value in the
    MorseRunner.ini file. Acceptable values are 1 through 5, the default is 3.
    Increase the buffer size for smooth audio without clicks and interruptions;
    decrease the size for faster response to keyboard commands.


  Competition duration

    The default duration of a competition session is 60 minutes. You can set it
    to a smaller value by changing the CompetitionDuration entry in the
    MorseRunner.ini file, e.g.:

    [Contest]
    CompetitionDuration=15


  Calls From Keyer

    If you have an electronic keyer that simulates a keyboard - that is, sends
    all transmitted characters to the PC as if they were entered from a keyboard,
    you can add the following to the INI file:

    [Station]
    CallsFromKeyer=1

    With this option enabled, the callsign entered into the CALL field is not
    transmitted by the computer when the corresponding key is pressed. This option
    has no effect in the WPX and HST competition modes.




STARTING A CONTEST

The contest can be started in one of four modes.

 Pile-Up mode: a random number of stations calls you after you send a CQ. Good
   for improving copying skills.

 Single Calls mode: a single station calls you as soon as you finish the
   previous QSO. Good for improving typing skills.

 WPX Compteition mode: similar to the Pile-Up mode, but band conditions and contest
   duration are fixed and cannot be changed. The keying speed and band activity
   are still under your control;

 HST Competition mode: all settings conform to the IARU High Speed Telegraphy
   competition rules.



To start a contest, set the duration of the exercise in the Run for NN Minutes
box (only for Pile-Up and Single Calls modes), and click on the desired mode
in the Run button's menu. In the Pile-Up and Competition mode, hit F1 or Enter
to send a CQ.




KEY ASSIGNMENTS

  F1-F8 - sends one of the pre-defined messages. The buttons under the input
    fields have the same functions as these keys, and the captions
    of the buttons show what each key sends.

  "\" - equivalent to F1.

  Esc - stop sending.

  Alt-W, Ctrl-W, F11 - wipe the input fields.

  Alt-Enter, Shift-Enter, Ctrl-Enter - save QSO.


  <Space> - auto-complete input, jump between the input fields.

  <Tab>, Shift-<Tab> - move to the next/previous field.

  ";", <Ins> - equivalent to F5 + F2.

  "+", ".", ",", "[" - equivalent to F3 + Save.

  Enter - sends various messages, depending on the state of the QSO;

  Up/Down arrows - RIT;

  Ctrl-Up/Ctrl-Down arrows - bandwidth;

  PgUp/PgDn, Ctrl-F10/Ctrl-F9, Alt-F10/Alt-F9 - keying speed,
    in 5 WPM increments.



WPX COMPETITION RULES

The exchange consists of the RST and the serial number of the QSO.

The score is a product of points (# of QSO) and multiplier (# of different
prefixes).

The bottom right panel shows your current score, both Raw (calculated
from your log) and Verified (calculated after comparing your log to other
stations' logs). The histogram shows your raw QSO rate in 5-minute blocks.

The log window marks incorrect entries in your log as follows:

  DUP - duplicate QSO.

  NIL - not in other station's log: you made a mistake in the callsign, or forgot
    to send the corrected call to the station.

  RST - incorrect RST in your log.

  NR - incorrect exchange number in your log.





SUBMITTING YOUR SCORE

If you complete a full 60-minute session in the WPX Competition mode, Morse Runner
will generate a score string that you can post to the Score Board on the web:
<http://www.dxatlas.com/MorseRunner/MrScore.asp>. Copy and paste your score
string into the box on the web page and click on the Submit button.

You can view your previous score strings using the File -> View Score menu
command.






VERSION HISTORY


1.68
  - TU + MyCall after the QSO is now equivalent to CQ



1.67
  - small changes in the HST competition mode.



1.65, 1.66
  - a few small bugs fixed.



1.61 - 1.64
  - small changes in the HST competition mode.



1.6
  - HST competition mode added;
  - CallsFromKeyer option added.



1.52
  - the CompetitionDuration setting added.



1.51
  - minor bugs fixed.



1.5
  - more realistic behavior of calling stations;
  - self-monitoring volume control;
  - more creative LIDS;
  - CW speed hotkeys;
  - WAV recording;
  - menu commands for all settings (for blind hams).



1.4
  - RIT function;
  - callsign completion/correction when sending;
  - faster response to keyboard commands;
  - bandwidth adjustment in 50 Hz steps;
  - the middle digit is selected when the cursor enters the RST field;
  - the QSO rate is now expressed in Q/hr;
  - the problem with the Finnish character set fixed.


1.3

  - some key assignments corrected for compatibility with popular contesting
    programs;
  - statistical models refined for more realistic simulation;
  - rate display added;
  - a few bugs fixed.


1.2 (first public release)

  - Competetion mode added;
  - some bugs fixed.


1.1
  - ESM (Enter Sends Messages) mode added;
  - a lot of bugs fixed.





DISCLAIMER OF WARRANTY

THE SOFTWARE PRODUCT IS PROVIDED AS IS WITHOUT WARRANTY OF ANY KIND. TO THE
MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THE AUTHOR FURTHER
DISCLAIMS ALL WARRANTIES, INCLUDING WITHOUT LIMITATION ANY IMPLIED WARRANTIES
OF MERCHANTABILITY, FITNESS  FOR A PARTICULAR PURPOSE, AND NONINFRINGEMENT.
THE ENTIRE RISK   ARISING OUT OF THE USE OR PERFORMANCE OF THE SOFTWARE PRODUCT
AND DOCUMENTATION REMAINS WITH RECIPIENT. TO THE MAXIMUM EXTENT PERMITTED BY
APPLICABLE LAW, IN NO EVENT SHALL  THE AUTHOR BE LIABLE FOR ANY
CONSEQUENTIAL, INCIDENTAL, DIRECT, INDIRECT, SPECIAL, PUNITIVE, OR OTHER DAMAGES
WHATSOEVER  (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF PROFITS,
BUSINESS INTERRUPTION, LOSS OF INFORMATION, OR OTHER PECUNIARY LOSS) ARISING
OUT OF THIS AGREEMENT OR THE USE OF OR INABILITY TO USE THE SOFTWARE PRODUCT,
EVEN IF THE AUTHOR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
DAMAGES.





END OF DOCUMENT