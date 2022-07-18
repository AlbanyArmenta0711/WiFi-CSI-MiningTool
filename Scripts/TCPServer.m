classdef TCPServer < handle
    %Creates a TCP connection given an address, port and a timeout
    %Developed by Jesús Albany Armenta García
    %January 19, 2022
    
    properties
        port
        timeout
        address
        connection
        status
    end
    
    methods
        %Class constructor
        function obj = TCPServer(address, port, timeout)
            obj.address = address; 
            obj.port = port;
            obj.timeout = timeout;
            obj.status = 0; %server closed
        end
        
        function startServer(obj)
            %Function to start TCP server and wait for a client connection
            obj.connection = tcpip(obj.address, obj.port, 'NetworkRole', 'server','Timeout',obj.timeout);
            try
                fopen(obj.connection); %wait for client connection
                obj.status = 1; %server up
            catch
                obj.status = 2; %server error
            end 
            
        end
        
        function closeServer(obj)
            %Function to close TCP server
            try
                fclose(obj.connection);
                obj.status = 0; 
            catch
                obj.status = 2; 
            end 
        end 
        
        function ipAddress = getMyIP(obj)
            %FOR WINDOWS SYSTEM
            %call ipconfig
            [~,commandText] = system('ipconfig');
            %mantain information only about the wireless LAN adapter until
            %subnet which is usually the line after the IPv4 line
            [text,~] = regexp(commandText,'Wireless\sLAN\sadapter\sWi-Fi.*Subnet','match');
            %process the text lines...
            text = strsplit(text{1},':');
            text = text{length(text)};
            text = strsplit(text,' ');
            ipAddress = text{2}; 
        end 
    end
end

