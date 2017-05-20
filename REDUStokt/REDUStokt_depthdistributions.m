function wbat = REDUStokt_depthdistributions(wbat,sa,depth_table,exprange)
% This function creates depth profiles per transect

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
        wbat(i).transect(j).wbat.depth = -(dpth - (1:s(1))*5);
        %disp(wbat(i).transect(j).wbat.depth )
        % Wbat sa values by depth
        %warning('Remove passings!')
        tind = (t0(1)<sa.time.datenum)&(t0(2)>sa.time.datenum);
        if isempty(find(tind))
            s0 = ['for deplyment ',num2str(i),', transect ',num2str(j),'.'];
            r0 = ['[',datestr(t0(1)),' to ',datestr(t0(2)),']'];
            r1 = ['[',datestr(sa.time.datenum(1)),' ',datestr(sa.time.datenum(end)),']'];
            disp(['No data ',s0,' within ',r0,'. Total data range is ',r1])
        end
        dum = sa.sa(:,tind);
        wbat(i).transect(j).wbat.sabydepth = mean(dum,2);
    end
end
