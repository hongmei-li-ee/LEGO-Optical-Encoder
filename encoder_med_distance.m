
% Hensikten med programmet er å ....
% Følgende sensorer brukes:
% - Lyssensor

% Følgende motorer brukes:
% - motor d


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%         EXPERIMENT SETUP, FILENAME AND FIGURE

clear; close all   % Alltid lurt å rydde workspace opp først
online = false;     % Online mot EV3 eller mot lagrede data?
plotting = false;  % Skal det plottes mens forsøket kjøres
filename = 'encoder_korttid.mat';  % Data ved offline

if online
    mylego = legoev3('USB');
    joystick = vrjoystick(1);
    [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);

    % Hvilke sensorer er koplet til?
    myColorSensor = colorSensor(mylego);
    resetRotationAngle(myColorSensor);
    motorD = motor(mylego,'D');
    motorD.resetRotation;
else
    % Dersom online=false lastes datafil.
    load(filename)
end

fig1=figure;
set(gcf,'units','normalized','outerposition',[0.1 0.3 0.6 0.6])
drawnow

% setter skyteknapp til 0, og initialiserer tellevariabel k
JoyMainSwitch=0;
k=0;
%----------------------------------------------------------------------
tp_last = 0;
omega_last = 0;
omega = zeros(1, 10000); % Pre-alloker for å unngå treghet
alfa = zeros(1, 10000);
vinkel = zeros(1, 10000); % Pre-allocate for the plot

while ~JoyMainSwitch
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                       GET TIME AND MEASUREMENT
    % Få tid og målinger fra sensorer, motorer og joystick

    k=k+1;               % oppdater tellevariabel

    if online
        if k==1
            % Spiller av lyd slik at du vet at innsamlingen har startet
            playTone(mylego,500,0.1)   % 500Hz i 0.1 sekund
            tic          % Starter stoppeklokke
            t(1) = 0;
        else
            t(k) = toc;  % Henter ut medgått tid
        end

        % Sensorer, bruk ikke Lys(k) og LysDirekte(k) samtidig
        Lys(k) = double(readLightIntensity(myColorSensor,'ambient'));
        %VinkelPosMotorD(k) = double(motorC.readRotation);

        % Data fra styrestikke. Utvid selv med andre knapper og akser.
        % Bruk filen joytest.m til å finne koden for knappene og aksene.
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
        JoyForover(k) = JoyAxes(2);
    else
        % Når k er like stor som antall elementer i datavektoren Tid,
        % simuleres det at bryter på styrestikke trykkes inn.
        if k==length(t)
            JoyMainSwitch=1;
        end

        if plotting
            % Simulerer tiden som EV3-Matlab bruker på kommunikasjon
            % når du har valgt "plotting=true" i offline
            pause(0.03)
        end
    end
    %--------------------------------------------------------------

    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %             CONDITIONS, CALCULATIONS AND SET MOTOR POWER
    % Gjør matematiske beregninger og motorkraftberegninger.
    % hvis motor er tilkoplet.


    % Tilordne målinger til variabler

    Nhull= 16;
    theta=2*pi/Nhull;
    threshold = 2;

    % +++++++++++signal+++++++++++++++++++++
    signal(k) = Lys(k) > threshold;
    square(k)=signal(k) > 0.5;
    if k > 1
        omega(k) = omega(k-1);
        alfa(k) = alfa(k-1);
        vinkel(k) = vinkel(k-1); % Keep the angle constant between pulses
    end
    %+++++++++++++++TID++++++++++++++++++++++++++++


    if k > 1 && signal(k-1)==0 && signal(k)==1
        % Calculate total angular distance (radians)
        vinkel(k) = vinkel(k-1) + theta;


        dt = t(k) - tp_last;
        omega(k) = theta / dt;% hastighet
        alfa(k) = (omega(k) - omega_last) / dt;% acceleration

        % Update for next time
        tp_last = t(k);
        omega_last = omega(k);

    end
    % ++++++++++++++++++++vinkelhastighet+++++++++++++++++++++++++

    if online
        % Setter pådragsdata mot EV3
        % (slett de motorene du ikke bruker)
        JoyForward = 50 *  JoyAxes(2);
        motorD.Speed = JoyForward;
        start(motorD)
    end
    %--------------------------------------------------------------

    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA
    %
    % Husk at syntaksen plot(Tid(1:k),måling(1:k))
    % gir samme opplevelse i online=0 og online=1 siden
    % alle målingene (1:end) eksisterer i den lagrede .mat fila

    % Plotter enten i sann tid eller når forsøk avsluttes
    if plotting || JoyMainSwitch
        figure(fig1)

        subplot(4,1,1)
        plot(t(1:k),signal(1:k)); 
        hold on
        stairs(t(1:k),square(1:k))
        hold off
        ylim([-0.1 1.1]); ylabel('Hull'); title('Lys/Signal')

        subplot(4,1,2)
        plot(t(1:k),omega(1:k)); ylabel('rad/s'); title('Vinkelhastighet $\tetha$')

        subplot(4,1,3)
        plot(t(1:k),alfa(1:k));  ylabel('rad/$s^2$'); title('Vinkelakkselasjon $\omega$')

        subplot(4,1,4)
        plot(t(1:k),vinkel(1:k)); ylabel('rad'); title('Vinkel $S$');
        xlabel('tid [s]')

        drawnow
    end
    %--------------------------------------------------------------
end


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%               STOP MOTORS
if online
    stop(motorD);
end
%------------------------------------------------------------------


