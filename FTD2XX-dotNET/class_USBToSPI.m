% This class uses the .NET wrapper for FTD2XX_NET on the windows platform
% such that Matlab could be directly used to achieve SPI communication
% by help of FTDI chips such as FT2232H, ...
%
% copyright by:
% Steffen Mauch (C) 2014
% email: steffen.mauch (at) gmail.com
%
% You can redistribute it and/or modify it under the terms of the GNU General Public
% License as published by the Free Software Foundation, version 2.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
% details.
%
% You should have received a copy of the GNU General Public License along with
% this program; if not, write to the Free Software Foundation, Inc., 51
% Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

classdef class_USBToSPI < handle
    
    properties (GetAccess = 'public', SetAccess = 'public')
        readTimeout             = uint32(200)
        writeTimeout            = uint32(10)
        latency                 = uint8(10)
        index                   = 0
    end
    
    properties (GetAccess = 'private', SetAccess = 'private')
       fd
       showAvailableMethods    = false
    end

    
    methods (Access = private)
        
        function self = init( self )

            % Place dll in directory of your choice.
            NET.addAssembly('C:\FTD2XX_NET.dll');

            % Helpful to view other function calling parameters.
            if( self.showAvailableMethods == true )
                methodsview( 'FTD2XX_NET.FTDI')
            end
                
            fdObj = FTD2XX_NET.FTDI;
            self.fd = fdObj; 
        end
        
    end
        
    methods
        function self = class_USBToSPI( methods )
            if( nargin > 0 )
                self.showAvailableMethods = methods;
            end
            self.init;
        end
        
        function self = openH( self )
            
            % see AN_135_MPSSE_Basic.pdf
            [ftStatus , nbOfDevices] = GetNumberOfDevices( self.fd , 0 );
            if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                error( 'GetNumberOfDevices failed with error: %s', ftStatus.ToString.char );
            end
            if( nbOfDevices <= 0 )
                error( 'no FTDI device found' );
            end
            
            ftStatus = OpenByIndex( self.fd, self.index );
            if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                error( 'OpenByIndex failed, tried index: %i, error: %s', self.index, ftStatus.ToString.char );
            end

            ftStatus = ResetDevice( self.fd );
            if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                error( 'ResetDevice failed with error: %s', ftStatus.ToString.char );
            end
            
            ftStatus = SetTimeouts( self.fd , uint32(self.readTimeout) , uint32(self.writeTimeout) );
            if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                error( 'SetTimeouts failed with error: %s', ftStatus.ToString.char );
            end
            
            ftStatus = SetLatency( self.fd , uint8( self.latency ) );
            if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                error( 'SetLatency failed with error: %s', ftStatus.ToString.char );
            end
            
            % reset controller
            ftStatus = SetBitMode( self.fd , uint8( 0 ) , uint8( 0 ) );
            if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                error( 'SetBitMode failed with error: %s', ftStatus.ToString.char );
            end
            
            % enable MPSSE mode
            ftStatus = SetBitMode( self.fd , uint8( 0 ) , uint8( 2 ) );
            if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                error( 'SetBitMode failed with error: %s', ftStatus.ToString.char );
            end
            
            
            % wait 50 ms for USB transmission etc.
            pause(0.05);
            
            
            % Loop-Back on
            data = hex2dec( '84' );
            ftStatus = Write( self.fd , data , length(data), 0 );
            if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                error( 'Write failed with error: %s', ftStatus.ToString.char );
            end

            [ftStatus , RxQueue] = GetRxBytesAvailable( self.fd , 0 );
            if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                error( 'GetRxBytesAvailable failed with error: %s', ftStatus.ToString.char );
            end
            
            if( RxQueue ~= 0 )
                error( 'MPSSE receive buffer should be empty' );
            end

            % synchronize MPSSE with bogus command
            data = hex2dec( 'AB' );
            ftStatus = Write( self.fd , data , length(data), 0 );
            if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                error( 'Write failed with error: %s; data: %s ', ftStatus.ToString.char, mat2str(data) );
            end
            
            [ftStatus , RxQueue] = GetRxBytesAvailable( self.fd , 0 );
            while( (RxQueue == 0) && (strcmp(ftStatus.ToString.char,'FT_OK') == 1) )
                [ftStatus , RxQueue] = GetRxBytesAvailable( self.fd , 0 );
            end
            
            % read the bytes such that loop-back could be switched off
            [ ftStatus , ~ , ~ ]  = Read( self.fd , RxQueue , 0 );
            if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                error( 'Write failed with error: %s', ftStatus.ToString.char );
            end

            
            % Loop-Back off
            data = hex2dec( '85' );
            ftStatus = Write( self.fd , data , length(data), 0 );
            if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                error( 'Write failed with error: %s; data: %s ', ftStatus.ToString.char, mat2str(data) );
            end
            
            [ftStatus , RxQueue] = GetRxBytesAvailable( self.fd , 0 );
            if( RxQueue ~= 0 )
                error( 'queue error');
            end
            if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                error( 'GetRxBytesAvailable failed with error: %s', ftStatus.ToString.char );
            end
            
            
            % 60MHz master Clock, Adaptive Clocking off, 3-Phase Clocking off
            data = [hex2dec( '8A' ) , hex2dec( '97' ) , hex2dec( '8D' ) ];
            [ ftStatus , ~ ] = Write( self.fd , data , length(data), 0 );
            if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                error( 'Write failed with error: %s; data: %s ', ftStatus.ToString.char, mat2str(data) );
            end

            % Set Divisor 
            data = [hex2dec( '86' ) , 9 , 0 ];
            [ ftStatus , ~ ] = Write( self.fd , data , length(data), 0 );
            if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                error( 'Write failed with error: %s; data: %s ', ftStatus.ToString.char, mat2str(data) );
            end
            
            % configure PINs
            data = [hex2dec( '80' ) , hex2dec( 'C9' ) , hex2dec( 'FB' ) ];
            [ ftStatus , ~ ] = Write( self.fd , data , length(data), 0 );
            if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                error( 'Write failed with error: %s; data: %s ', ftStatus.ToString.char, mat2str(data) );
            end

            data = [hex2dec( '0' ) , hex2dec( '0' ) ];
            [ ftStatus , ~ ] = Write( self.fd , data , length(data), 0 );
            if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                error( 'Write failed with error: %s; data: %s ', ftStatus.ToString.char, mat2str(data) );
            end
            
            % write 0x00 than read to clear buffer (is required, but why
            % ... !?!?
            data = [ hex2dec( '10' ) , 0 , hex2dec( '00' ) , 0 ];
            [ ftStatus , dataWritten ] = Write( self.fd , data , length(data), 0 );
            if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                error( 'Write failed with error: %s; data: %s ', ftStatus.ToString.char, mat2str(data) );
            end
            if( dataWritten ~= length(data) )
                error( 'wrong number of bytes in RX available' );
            end
            
            % pause to be sure every USB packet is already send
            pause(0.1);
            
            [ ftStatus , RxQueue ] = GetRxBytesAvailable( self.fd , 0 );
            if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                error( 'GetRxBytesAvailable failed with error: %s', ftStatus.ToString.char );
            end

            [ ftStatus , InputData , ~ ]  = Read( self.fd , RxQueue , 0 );
            if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                error( 'Read failed with error: %s; data: %s ', ftStatus.ToString.char, mat2str(InputData) );
            end
            
        end
        
        function self = loop( self )

            while( 1 )
                %disp( '--------------------------restart--' );
                
                DataPackage = [ bin2dec('10000010') zeros(1,28) zeros(1,2)];
                amountRead = 10;
                
                %hex2dec( '10' ) , length( DataPackage ) - 1 , hex2dec( '00' ) , DataPackage , ...

                data = [ hex2dec( '80' ) , hex2dec( '09' ) , hex2dec( '0b' ) , ...
                     hex2dec( '10' ) , length( DataPackage ) - 1 , hex2dec( '00' ) , DataPackage , ...
                     hex2dec( '20' ) , amountRead-1 , hex2dec( '00' ) , ...
                     hex2dec( '80' ) , hex2dec( '01' ) , hex2dec( '0b' ), ...
                     ];
                                                  
                [ ftStatus , rxWritten ] = Write( self.fd , data , length(data), 0 );        
                if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                    error( 'Write failed with error: %s; data: %s ', ftStatus.ToString.char, mat2str(data) );
                end
                if( rxWritten ~= length(data) )
                    error( 'to less data written' );
                end
                
                % pause must match with latency
                pause( (2.0*double(self.latency))/1000.0 );
                
                [ftStatus , rxQueue] = GetRxBytesAvailable( self.fd , 0 );
                if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                    error( 'GetRxBytesAvailable failed with error: %s', ftStatus.ToString.char );
                end
                if( rxQueue ~= amountRead )
                    error( 'wrong number of bytes in RX available' );
                end
                
                InputData = NET.createArray('System.Byte',100);
                [ ftStatus , BytesRead ]  = Read( self.fd , InputData, rxQueue , 0 );
                if( (strcmp(ftStatus.ToString.char,'FT_OK') ~= 1) )
                    error( 'Read failed with error: %s; data: %s ', ftStatus.ToString.char, mat2str(InputData) );
                end
                
                if( InputData.Length == 0 )
                   disp('happend');
                else
                   test = uint8(InputData);
                   %BytesRead
                   if( isempty(test) ) 
                       test = 9;
                   end
                   
                   fprintf( '\ndata: ' );
                   fprintf( '0x%02x ', test(1:BytesRead)' );
                   fprintf( '\n nbReceived: 0x%02x\n', rxQueue ); 
                end
                

                pause( 0.001 );

            end
        end
        
        function delete( obj )
           Close(obj.fd);
        end
    end
    
end