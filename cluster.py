from sklearn.cluster import KMeans
from sklearn.decomposition import PCA
from sklearn import preprocessing
import os, os.path
import numpy as np
import pandas as pd
import sys, argparse
import matplotlib.pyplot as plt

parser = argparse.ArgumentParser()
parser.add_argument("--sample-by-latent", "-s", required=True)
parser.add_argument("--meta", "-m", required=True)
parser.add_argument("--outdir", "-o", required=True)
args = parser.parse_args()

sample_by_latent_df = pd.read_csv(args.sample_by_latent, index_col=0)

# encode tumor type as an integer
le = preprocessing.LabelEncoder()
meta_df = pd.read_csv(args.meta, index_col=0)
le.fit(list(meta_df.iloc[:,0]))
y_raw = list(map(lambda x: str(x), list(sample_by_latent_df.join(meta_df).loc[:,'tumorType']))) 
y = le.transform(y_raw)

X = sample_by_latent_df
pca = PCA()
pca.fit(X)
X_new = pca.transform(X)


plt.subplot(1,2,1)
for i in range(len(le.classes_)):
  ind = (y == i)
  xs = X_new[ind,0]
  ys = X_new[ind,1]
  plt.scatter(xs, ys, label=le.classes_[i])
plt.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)
plt.savefig(os.path.join(args.outdir, 'scatter.png'))

# TODO
kmeans = KMeans(n_clusters=6).fit(sample_by_latent_df)
