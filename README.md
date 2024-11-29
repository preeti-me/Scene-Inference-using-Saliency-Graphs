# Scene-Inference-using-Saliency-Graphs-with-Trust-Theoretic-Semantic-Information-Encoding
The main contributions of the paper are: (i) A trust-theoretic approach for estimation of the optimal edge-weights using saliency information (volumetric) of the nodes in the saliency graphs to enhance scene inference accuracy. Experimental results show that the proposed approach is robust and efficient for matching even small subgraphs over large complex graphs, demonstrating the optimality of the proposed weighting strategy.  
(ii) A scene inference algorithm through a graph-matching approach involves weighted triplet matching. Our analysis demonstrates that the proposed approach obtains the best scene inference accuracy, i.e. $0.91$, among all the SOTA methods due to effective encoding of scene structure. 
(iii) Improved robustness of scene inference against erroneous edges by incorporating non-edge triplet matching in the graph-matching approach.

## Dataset 
https://drive.google.com/file/d/1t4Fzn77WMBg-E1M-bi_DI4kwZchx0Oga/view?usp=sharing


## Citation
If you use the source code, please cite the following paper

```bash

@ARTICLE{10770563,
  author={Meena, Preeti and Kumar, Himanshu and Yadav, Sandeep},
  journal={IEEE Signal Processing Letters}, 
  title={Scene Inference using Saliency Graphs with Trust-Theoretic Semantic Information Encoding}, 
  year={2024},
  volume={},
  number={},
  pages={1-5},
  doi={10.1109/LSP.2024.3508538}}

@article{meena2024volumetric,
  title={A Volumetric Saliency Guided Image Summarization for RGB-D Indoor Scene Classification},
  author={Meena, Preeti and Kumar, Himanshu and Yadav, Sandeep},
  journal={IEEE Transactions on Circuits and Systems for Video Technology},
  year={2024},
  publisher={IEEE}
}
```

## Acknowledgements

- Sun RGB-D Dataset
- node2vec
