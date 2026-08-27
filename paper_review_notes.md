# Paper Review Notes — Outstanding Items

Remaining issues found during the proofreading pass on 2026-08-27. The
grammar and spelling errors have already been fixed in `sections/*.tex`;
everything below was **deliberately left unchanged** because it needs an
author decision (wording, notation, or content), not a mechanical fix.

Line numbers refer to the state of the files after the grammar pass.

Sections 1-5 come from the proofreading pass; sections 6-7 come from a
follow-up review of the mathematics. **Section 6 is the highest priority** --
it contains two items that are wrong, not merely unclear.

---

## 1. Likely factual / content errors

- **`sections/experiment.tex:171` — "qualitative" should probably be "quantitative".**
  "Table~\ref{tab:rendered_map} shows the qualitative results for rendered maps."
  Table II is a table of numbers; the *qualitative* results are Figure 5.

- **`sections/experiment.tex:171` — same figure cited twice for different things.**
  The sentence opens with "...particularly evident in the quad\_hard sequence in
  Figure~\ref{fig:rendered_map}" and ends with "...evident in the reduction of
  high-error points shown in Figure~\ref{fig:rendered_map}". The second reference
  may be intended for the error histogram (`fig:error_histogram`) or for a
  per-point error figure.

- **`sections/methodology.tex:221` vs. Eq. (11) — hyperparameters that do not appear in the loss.**
  The implementation details list $\lambda_\text{coarse}$, $\lambda_\text{fine}$,
  $\lambda_\text{d}$, $\lambda_\text{i}$ and $\lambda_\text{h}$, but the final loss
  in Eq. (11) contains only $\lambda_\text{coarse}$, $\lambda_d$ and $\lambda_h$.
  There is no $\lambda_\text{fine}$ term and no intensity loss for $\lambda_\text{i}$
  anywhere in the paper. Either add them to Eq. (11) or drop them from the list.

- **`sections/experiment.tex:152` — unresolved TODO left in the source.**
  `% TODO: rewrite this part to mention why we are doing these evaluations.`

## 2. Math notation

- **`sections/methodology.tex:11` — $\mathbf{p} \subset SE(3)$** should almost
  certainly be $\mathbf{p} \in SE(3)$ (a pose is an element, not a subset).

- **`sections/methodology.tex:11` — $\mathbf{x} \in \mathbb{R}^5$** deserves a word
  of explanation (presumably 3D position + 2D view direction), since a "volume
  sample" reads as 3D.

- **`sections/methodology.tex:24` — off-by-one in the pose set.**
  "Given $S$ number of LiDAR scans ... $P = \{\mathbf{p}_s\}_{s=0}^{S}$" defines
  $S+1$ poses for $S$ scans. Use $s=1..S$ or $s=0..S-1$.

- **`sections/methodology.tex:180` — `ln` is typeset as italic variables.**
  Should be `\ln` (upright) inside the KL-divergence equation.

## 3. Wording that is grammatical but reads oddly

- **`root.tex:92` (abstract)** — "for joint optimization of LiDAR map and poses"
  → "of the LiDAR map and poses". Also "which is tailored using efficient volume
  sampling" is a slightly awkward construction.

- **`sections/introduction.tex:6`** — "Contrary to RGB images which contain rich
  texture..." → "Unlike RGB images, which contain rich texture...". Missing comma
  before the non-restrictive clause; "Contrary to" is usually used for propositions,
  not objects.

- **`sections/methodology.tex:61`** — "significantly eliminates the estimated range
  ambiguity". *Eliminate* is absolute; "significantly reduces" or plain "eliminates".

- **`sections/experiment.tex:162`** — "was used as an off-the-shelf LiDAR odometry"
  → "odometry method/module"; and "the proposed method is flexible to work with
  other algorithms" → "can flexibly work with" / "is compatible with".

- **`sections/experiment.tex:478` (Limitations)** — "superior capabilities in mapping
  and BA for scenes" is vague ("for scenes"), and the sentence structure
  ("While our algorithm has demonstrated X, large-scale sequences might be
  challenging") shifts subject mid-sentence.

## 4. Consistency nits

- **British vs. US spelling:** `sections/methodology.tex:61` uses "optimising";
  every other occurrence in the paper uses "optimiz-".

- **Capitalization of "Chamfer":** `sections/experiment.tex:475` writes
  "chamfer distance"; everywhere else it is "Chamfer".

- **Figure-caption punctuation:** `sections/methodology.tex:83` runs the bold
  lead-in straight into the next sentence with no punctuation
  ("...canteen\_day sequence} Our sampling method..."). Every other caption ends
  the bold lead-in with a period.

- **Cross-reference style:** "equation \ref{...}" (lowercase, `sections/methodology.tex:61`
  and `:117`) vs. capitalized "Figure~"/"Section~" elsewhere; IEEE style is
  "(1)" or "Eq. (1)". Also inconsistent `~` vs. plain space, and
  "Figure~\ref{...} (c)" vs. "Figure \ref{...}(c)" spacing.

- **Table-caption wording:** the three table captions are slightly different from
  one another in how they describe bold/underline and the `---` failure marker.

## 5. Submission hygiene

- **`root.tex:74` still says `Anonymous Author(s)`**, although recent commits added
  author names to the README on this `submission/arxiv` branch.

- **Stale commented-out duplicates** of revised paragraphs remain in the source and
  still contain the original errors (e.g. `sections/experiment.tex:157`,
  `sections/methodology.tex:96-98`, `sections/conclusion.tex`). Harmless for the
  build, but worth clearing before release so the wrong version is not revived.

---

# Mathematical Review (added 2026-08-27)

## 6. Probable errors in the equations (highest priority)

- **Eq. (10), `sections/methodology.tex:180` -- the KL divergence is inverted.**
  As written,
  $\mathcal{L}_\text{termination} = \sum_\mathbf{r}\sum_n h^*(z_n)\ln\!\big(\hat{h}(z_n)/h^*(z_n)\big)$,
  but $D_\text{KL}(h^*\Vert\hat{h}) = \sum h^*\ln(h^*/\hat{h})$ -- the ratio is the
  wrong way round, so the expression equals $-D_\text{KL}$. Substituting the
  one-hot $h^*$ of Eq. (11) gives $\mathcal{L}_\text{termination} = \ln\hat{h}(z_{n^*})$,
  and minimizing it drives the termination probability at the correct bin to *zero*.
  Swap the ratio (or negate the sum). **Check against the implementation** -- the
  code is presumably correct and this is a transcription error.
  Two follow-ons once fixed: with a one-hot target the loss reduces to
  $-\ln\hat{h}(z_{n^*})$, which is worth stating explicitly, and the $0\ln 0$ terms
  need the usual "by convention $0\ln 0 = 0$" remark.

- **Eq. (5), `sections/methodology.tex:51-57` -- the chain rule is incomplete.**
  $\hat{h}(z_i)$ depends on *every* sample $j \le i$ through the accumulated
  transmittance $\exp(-\sum_{j<i}\hat\sigma_j\delta_j)$, so
  $\partial\hat{h}(z_i)/\partial\mathbf{x}_i$ is only one term of the true derivative.
  It should read

  $$\frac{\partial \hat{D}}{\partial \boldsymbol{\xi}}
    = \sum_{i=1}^{N} z_i \sum_{j \le i}
      \frac{\partial \hat{h}(z_i)}{\partial \tilde{\mathbf{x}}_j}
      \frac{\partial T(\mathbf{x}_j;\mathbf{p})}{\partial \boldsymbol{\xi}}$$

  Two smaller problems in the same equation: the first factor must be taken with
  respect to the *transformed* sample $\tilde{\mathbf{x}}_j = T(\mathbf{x}_j;\mathbf{p})$
  (as written, $\mathbf{x}_i$ is simultaneously the input to $T$ and the variable
  being differentiated), and $\partial/\partial\mathbf{p}$ with $\mathbf{p}\in SE(3)$
  should be $\partial/\partial\boldsymbol{\xi}$ on the $\mathfrak{se}(3)$ coordinates
  that are actually optimized. The $\sum_i$ has also lost its bounds, unlike
  Eqs. (2)-(3). The same partial appears in the Fig. 2(b) caption and at
  `sections/methodology.tex:59`.

- **Eq. (13), `sections/methodology.tex:210` -- returns an index, not a distance.**
  $z_\text{map} = \arg\max_i(h(z_i)/\delta_i)$ evaluates to $i^*$. Write
  $i^* = \arg\max_i(\cdot)$ and $z_\text{map} = z_{i^*}$. Also $h$ appears without
  its hat here, unlike everywhere else.

## 7. Eq. (4): the reviewer's complaint about the arg-min

The objective $\mathcal{L}(\hat{D} \mid D)$ contains neither $P$ nor $\Theta$, so the
$\arg\min$ has no visible argument. The `|` also reads as a conditional probability
rather than "prediction vs. measurement". Recommended minimal fix -- thread the
variables through $\hat{D}$ and use a comma:

```latex
\begin{equation}\label{eq:NeLD_BA_problem_def}
	P^*, \Theta^* = \operatorname*{arg\,min}_{P,\,\Theta}\;
	\mathcal{L}\!\left(\hat{D}(P, \Theta),\; D\right)
\end{equation}
```

with matching arguments propagated into Eqs. (1) and (2)
($\hat{\sigma}(\mathbf{x};\mathbf{p},\Theta)$ and $\hat{D}(\mathbf{r};\mathbf{p},\Theta)$),
plus one sentence noting that $P$ enters through $T(\cdot)$ and $\Theta$ through
$f(\cdot)$, which is what makes the problem jointly differentiable.

A fully explicit alternative, $\sum_{s=1}^{S}\sum_{\mathbf{r}\in\mathcal{R}_s}
\mathcal{L}(\hat{D}(\mathbf{r};\mathbf{p}_s,\Theta), D(\mathbf{r}))$, would require
dropping $\sum_\mathbf{r}$ from Eqs. (9)-(10) and defining those losses per-ray,
otherwise the ray sum is counted twice.

Minor, same equation: the `\begin{split}` wrappers on Eqs. (1) and (4) are doing
nothing (single line, no alignment) and can be removed.

---

*Sections 8 and 9 (undefined/under-specified quantities, and internal
inconsistencies in the math) were reviewed by the author on 2026-08-27 and
dismissed as acceptable as written; they have been removed from this list.*
