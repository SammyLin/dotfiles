
function script:filename([string] $path) {
   return [System.IO.Path]::GetFileName($path)
}
function stars {
   return (new-object string ('*', 80))
}

$BASE = 'g:\backups'
$today = [datetime]::Today.ToString("yyyyMMdd");

$dest = "$BASE\$today"
$log = "$dest\log.txt"

if ( -not (test-path $dest) ) {
   mkdir $dest
}

#
# write header
#
write (stars) >> $log
write "Backup procedure starting at " `
      ([string][datetime]::Now) >> $log
write (stars) "`r`n`r`n" >> $log

#
# stop CVS services 
#
net stop cvsnt >> $log
net stop cvslock >> $log

#
# backup our set of folders
#
$objfiles = ('*.swp *.obj *.exe *.dll *.pdb *.pch *.idb *.ilk *.lib *.lck *.ncb *.plg *.tlb *.suo')
$folders = ( 
   ('e:\CVS', ''), 
   ('e:\devdeo', ''),
   ('e:\git-data', ''),
   ('e:\home', '*.swp'),
   ('e:\projects', $objfiles),
   ('e:\opensource', $objfiles),
   ('e:\tools', '')
)

$folders | %{
   $name = filename($_[0])
   $excludes = $_[1].Split(' ')
   robocopy $_ "$dest\$name" *.* /E /ZB /NP /XF $excludes >> $log
}

#
# backup our VPC data file
#
robocopy 'E:\vpc\' $dest 'datos.vhd' /NP >> $log

#
# restart CVS services 
#
#net start cvsnt >> $log
#net start cvslock >> $log

#
# write footer
#
write "`r`n`r`n" (stars) >> $log
write "Backup procedure finished at " `
      ([string][datetime]::Now) >> $log
write (stars) >> $log

write "Backup done. Check log file for details."
write $log
