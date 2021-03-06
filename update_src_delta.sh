#!/bin/bash
# update the source by using the "delta" patch (apply the diff between the old src and new src to the gnunized src) of the ifort source.
# Use this first so that any changes I made manually to the source code will be kept.
dirdiff=vdiff
function clean_noGUI {
    rm GUI.f90 plot.f90 && rm *.a
}
#First let's generate the patch
if [ -d $dirdiff ];then
    rm -rf $dirdiff
fi
mkdir $dirdiff
cd $dirdiff
pushd .
#Get the old src
ln -s ../current_src.zip ./
unzip current_src.zip
cd Mult*
find . -name '* *' -print0|xargs -0 rm -f
#rm file not mentioned in the noGUI Makefile
clean_noGUI
sed -i -e 's/grep/grep -a/g' noGUI.sh
sh noGUI.sh && mv noGUI ../src_old
rm ../src_old/Makefile
popd && mv Multi*src_Linux src_full_old
../gnuize_delta.sh src_old
pushd .
#Get my patch for current src
if [ -d ../src.orig ]; then
    cp -pr ../src.orig src_gnu
else
    cp -pr ../src src_gnu
fi
#Now get the patch_to_gnu for each old file:
cd src_old
for currFile in *;do
    diff -uNr ${currFile} ../src_gnu/${currFile} > ../${currFile}.to_gnu.patch
done
cd ..
#remove the 0 length patch_to_gnu files.
for pat_gnu in *.to_gnu.patch;do
    if [ -s ${pat_gnu} ]; then
        echo "Patch to GNU port: ${pat_gnu}"
    else
        rm ${pat_gnu}
    fi
done
#Get the new src and get the delta diff from the old to new ifort src
ln -s ../latest_src.zip ./
unzip latest_src.zip
cd Mult*
find . -name '* *' -print0|xargs -0 rm -f
clean_noGUI
sed -i -e 's/grep/grep -a/g' noGUI.sh
sh noGUI.sh && mv noGUI ../src_new
rm ../src_new/Makefile
popd && mv Multi*src_Linux src_full_new
../gnuize_delta.sh src_new
DELTA_DIFF=patch_to_delta_update.diff
diff -uNr src_old src_new > ${DELTA_DIFF}
#backup the original src
cd ..
if [ -d src.orig ];then
    rm -r src
    cp -pr src.orig src
else
    cp -pr src src.orig
fi
#apply the patch
cd src
patch -p1 --no-backup-if-mismatch < ../$dirdiff/${DELTA_DIFF}
#patch --no-backup-if-mismatch < population.patch
cd .. #we are in $dirdiff
# rename .zip #should be down manually
#mv current_src.zip previous_src.zip
#mv latest_src.zip current_src.zip
numRej=`ls -l src/*rej 2> /dev/null | wc -l`
echo "Number of rejected patches is: ${numRej}"
if [ $numRej -gt 0 ];then
    echo "Trying to un_GNU and update..."
    cd src
    for currRej in *.rej;do
        currSrc=${currRej/.rej}
        mv ${currSrc}.rej ${currSrc}.delta_update.patch
        patch -R ${currSrc} < ../${dirdiff}/${currSrc}.to_gnu.patch
    done
    numFailed=`ls -l *.rej 2> /dev/null |wc -l`
    if [ ${numFailed} -gt 0 ];then
        echo "un_GNU failed! Existing..."
        exit
    else
        echo "un_GNU done!"
    fi
    echo "Updating..."
    for currUp in *.delta_update.patch;do
        currSrc=${currUp/.delta_update.patch}
        patch ${currSrc} < ${currUp}
    done
    numFailed=`ls -l *.rej 2> /dev/null |wc -l`
    if [ ${numFailed} -gt 0 ];then
        echo "Updating failed! Existing..."
        exit
    else
        echo "Updating done!"
    fi
    for currUp in *.delta_update.patch;do
        currSrc=${currUp/.delta_update.patch}
        patch ${currSrc} < ../${dirdiff}/${currSrc}.to_gnu.patch
    done
    numFailed=`ls -l *.rej 2> /dev/null |wc -l`
    if [ ${numFailed} -gt 0 ];then
        echo "Re-patching failed!" 
        echo "Please apply .rej manually and delete *.delta_update.patch and *.orig!"
        cp *.rej ../manually_patched/
        exit
    else
        echo "Re-patching done! Try to compile!"
        rm *.delta_update.patch
        rm *.orig
    fi
fi
