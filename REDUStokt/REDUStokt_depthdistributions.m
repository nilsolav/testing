function wbat = REDUStokt_depthdistributions(wbat,sa,depth_table,exprange,type)
% This function creates depth profiles per transect

% This is the time before after the Shale's cirlce where we use the sa data
% from the vessel 5nmi/speed(nmis/h) /24h
dt=(5/10)/24;

s=size(sa.sa);
for i=exprange
    for j=1:length(wbat(i).transect)
        t0 = [wbat(i).transect(j).start.time wbat(i).transect(j).stop.time];
        % Average time as time stamp
        wbat(i).transect(j).avgtime = .5*(wbat(i).transect(j).stop.time+wbat(i).transect(j).start.time);
        wbat(i).transect(j).avglat = .5*(wbat(i).transect(j).stop.lat+wbat(i).transect(j).start.lat);
        wbat(i).transect(j).avglon = .5*(wbat(i).transect(j).stop.lon+wbat(i).transect(j).start.lon);
        % wbat depth vector
        
        % Find depth of the transducer (channnel 1 = øverst i LSSS =
        % nederst i vannsøyla)
        %        depth_table(:,1)>t0(1)
        dpth=depth_table(find(depth_table(:,1)<t0(1),1, 'last' ),2);
        %disp(wbat(i).transect(j).wbat.depth )
        % Wbat sa values by depth
        %warning('Remove passings!')
        tind = (t0(1)<sa.time.datenum)&(t0(2)>sa.time.datenum);
        if isempty(find(tind))&~strcmp(type,'vesselbeforeafter')
            s0 = ['for deplyment ',num2str(i),', transect ',num2str(j),'.'];
            r0 = ['[',datestr(t0(1)),' to ',datestr(t0(2)),']'];
            r1 = ['[',datestr(sa.time.datenum(1)),' ',datestr(sa.time.datenum(end)),']'];
            disp(['No data ',s0,' within ',r0,'. Total data range is ',r1])
        end
        dum = sa.sa(:,tind);
        if strcmp(type,'wbat')
            wbat(i).transect(j).wbat.sabydepth = mean(dum,2);
            wbat(i).transect(j).wbat.depth = -(dpth - (1:s(1))*5);
            wbat(i).transect(j).wbat.transducerdepth = dpth;
            nilsind = wbat(i).transect(j).wbat.depth>0;
            if (sum(wbat(i).transect(j).wbat.sabydepth(nilsind))>0)
                disp(['Wbat ',num2str(i),', transect ',num2str(j),', ',datestr(t0(1)),' ',datestr(t0(2))])
                nils = find(wbat(i).transect(j).wbat.depth(end-3:end)>0);
                disp(dpth)
                disp(wbat(i).transect(j).wbat.depth(nilsind))
                disp(wbat(i).transect(j).wbat.sabydepth(nilsind)')
            end
            wbat(i).transect(j).wbat.sabydepth(nilsind)=NaN;
        elseif strcmp(type,'vessel')
            wbat(i).transect(j).vessel.sabydepth = mean(dum,2);
            wbat(i).transect(j).vessel.depth = -5*(1:size(dum,1))+2.5;
        elseif strcmp(type,'vesselbeforeafter')
            % Get the data before and after a wbat deplyment.
            tind_before = find(sa.time.datenum<t0(1),4,'last');
            tind_after = find(sa.time.datenum>t0(2),4,'first');
            %tind_before = (sa.time.datenum<t0(1))&(sa.time.datenum>(t0(1)-dt));
            %tind_after = (sa.time.datenum>t0(2))&(sa.time.datenum<(t0(2)+dt));
            wbat(i).transect(j).vesselbeforeafter.depth = -5*(1:size(dum,1))+2.5;
            wbat(i).transect(j).vesselbeforeafter.before.sabydepth = mean(sa.sa(:,tind_before),2);
            wbat(i).transect(j).vesselbeforeafter.after.sabydepth = mean(sa.sa(:,tind_after),2);
        end
    end
    % Calculate average per deplyment
    
end

