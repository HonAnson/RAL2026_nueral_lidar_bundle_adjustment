Run project with:
```bash
latexmk -pdf root.tex
```
Clean the compiler with:
```
latexmk -C root.tex
```

### TODO
- update video

#### Figures

#### Text
30. Proofread the entire thing with correction notes

#### Others

#### Done
- Maybe add error histogram __ok__
- mention newer college problem that is mentioned in other papers __ok__
- use 20cm threshold for rendered map, align with other papers __ok__
2. Make video __ok__
1. Make a name for this paper? __ok__
- Use topdown map for math hard __ok__
34. Add red box in images __ok__
8. Put architecture / quick result image in first page __ok__
1. Add figure in first page, what figure would be a good idea to put into the first page? - __ok__
1. Update traj plot with arrows showing direction, make line thicker - __ok__
4. Add more evaluation metrics in mapping results - __ok__
4. PIN of ICRA submission portal - __ok__
5. Reorganisation of Implementation Details - __ok__
5. Make qualitative result smaller - __ok__
6. Justification of using FAST-LIO2 --> off the shelf, other lidar odometry estimation is appplicable. - __ok__
7. Make introduction longer - __ok__
9. Update contribution - __ok__
10. use ABCD instead of subsection in Related work - __ok__
11. Update fundamental difference between RGB-NeRF-BA vs LiDAR-NeRF-BA - __ok__
12. Update figure 1a to include comparison between LiDAR and camera, also use real lidar image in figure 1 - __ok__
13. Remove cube bound image - __ok__
14. Improve ray distribution image - __ok__
15. Change line so that I'm using line style in ray distribution image - __ok__
16. define "smooth gradient" with \gamma^{smooth}(1/2k{pi}) - __ok__
17. Explain more in experiment results - __ok__
18. Make qualitative result smaller, combine NC and FP results in raw maps - __ok__
20. Add more comparison metrics in rendered map results - __ok__
21. Update traj image (remove background, make font bigger, line style) - __ok__
22. Use less iteration for ablation study - __ok (didn't preform as well for mapping result. So use the original iters instead)__
26. Fix font size in all images - __ok__
27. Change wordings in ablation study. - __ok__
29. Use math equations for cube bound - __ok__
23. Remove NC result in ATE quantative result - __ok__
24. Remove online in reference and use jornal names instead - __ok__


### Meeting 20250911
to discuss:
- 4dndf problem, should I use official implementation for their quad easy?
- highlights for images
- make first figure an overview
- Figure 2, add wall for RGB NeRF, add lidar with multi view. Make RGB NeRF and LiDAR NeRF consistent to show contrast.
- Picture in a picture for figure 4
- fix trajectory with new lines & plots
- fix references with consistent fonts
- 

- Keywords: mapping, SLAM, range sensing




### Meeting 20250905
*** Introduction
- Introduction too short, BA is a difficult problem (e.g. many points)
- Can put architecture & quick result in first page
- Update contribution, e.g. New strategy, inspired by xyz insight

*** Related work
- Use subsection ABCD instead of the current method
- Upate fundamental difference for RGB-NeRF-BA vs LiDAR-NeRF-BA

*** Methodology
- Add figure (a), a lidar without ambiguity problem, then no need to use Figure 1(a)(b)
- Screencap an actual LiDAR sensor to replace 
- Fix figure 1, this is important
- Remove cube bound image, improve ray termination distribution image
- Change line style for images 
- Indicate k \in 0 to L-1 
- Define smooth gradient with \gamma^{smooth}(1/2k{pi})

*** Experiment
- Explain more consistent, smoother, more challenging sequence, point out area worth they seeing
- Update traj image (remove background, make font bigger, line style)
- Remove NC result in ATE quantative result
- Use less iteration for ablation study - ok

*** Reference
- Remove online in reference

Ideally, introduction finishes at the end of first page. 
Piroritise ablation rerun. 

<!-- 
% April 2, 2003
% IEEEtran.bst is the official BibTeX style for authors of the Institute of
% Electrical and Electronics Engineers (IEEE) Transactions journals and
% conferences. It also may have applications in other academic work such as
% theses and technical reports.

% IEEEtran.bst is a very comprehensive BibTeX style which provides many
% features beyond the standard BibTeX styles - including full support
% for references of online documents, patents, periodicals and standards.
% See the provided user manual for detailed usage information.


%  Enjoy!

% Michael Shell
% mshell@ece.gatech.edu

% *******
% Version 1.11 (2003/04/02) changes:

%  1) Corrected problem with underscores in URLs when using url.sty.

% No changes needed in the documentation.

% Minor updates have been made to the IEEEfull.bib and IEEEabrv.bib 
% string definitions. 



% ********************* Files **********************

% README                 - This file.

% IEEEtran.bst           - The IEEE BibTeX style file.

% IEEEtranS.bst          - A version of IEEEtran.bst that sorts the
%                          entries. May be of interest for (non-IEEE) work
%                          such as theses. (Do not use for IEEE work.)

% IEEEtran_bst_HOWTO.pdf - The user manual.

% IEEEexample.bib        - An example BibTeX database that contains the
%                          references shown in the user manual.

% IEEEabrv.bib           - String definitions for the abbreviated names of
%                          IEEE journals. (For use with IEEE work.)
                         
% IEEEfull.bib           - String definitions for the full names of
%                          IEEE journals. (Do not use for IEEE work.)

% IEEEbcpat.bib          - Obsolete string definitions provided by older
%                          versions of IEEE BibTeX .bst files. (Do not
%                          use for IEEE work.)




% **********************************************************************
%  Legal Notice:
%  This code and advice is offered as-is without any warranty either
%  expressed or implied; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE!
%  User assumes all risk.
%  In no event shall IEEE or any contributor to this code
%  be liable for any damages or losses, including, but not limited to,
%  incidental, consequential, or any other damages, resulting from the
%  use or misuse of any information contained here.
 
%  All statements made here are the opinions of their respective
%  authors and are not necessarily endorsed by the IEEE.

%  This code/text is distributed under the Perl Artistic License 
%  ( http://language.perl.com/misc/Artistic.html ) 
%  and may be freely used, distributed and modified.
%  Retain all contribution notices and credits.
% ********************************************************************** -->
