#!/usr/bin/env python
from sklearn.cluster import KMeans
from sklearn.decomposition import PCA
from sklearn import preprocessing
from sklearn.metrics import adjusted_rand_score
import itertools as it
import os, os.path
import numpy as np
import pandas as pd
import sys, argparse
import matplotlib.pyplot as plt

class_labels_map = {
  'Cutaneous Neurofibroma': 'cNF',
  'High Grade Glioma': 'HGG',
  'Low Grade Glioma': 'LGG',
  'Malignant Peripheral Nerve Sheath Tumor': 'MPNST',
  'Massive Soft Tissue Neurofibroma': 'MSTN',
  'Neurofibroma': 'NF',
  'Plexiform Neurofibroma': 'pNF',
  'nan': 'NA'
}

# TODO data may have NA values (which are written by R as "NA" in the csv)

parser = argparse.ArgumentParser(description="""
Cluster and visualize a data matrix given by --sample-by-latent
""")
parser.add_argument("--data", "-d", required=True, help='sample x feature data matrix')
parser.add_argument("--meta", "-m", required=True, help='sample x meta annotation matrix (rows in <meta> correspond to rows in <data>)')
parser.add_argument("--outdir", "-o", required=True)
parser.add_argument("--remove-columns", "-r", required=False, nargs="+", help="Columns to remove, given by column name")
args = parser.parse_args()

data_df = pd.read_csv(args.data, index_col=0)
col_data = []
if args.remove_columns is not None:
  for remove_column in args.remove_columns:
    col_data.append(data_df.pop(remove_column))

# encode tumor type as an integer
le = preprocessing.LabelEncoder()
meta_df = pd.read_csv(args.meta, index_col=0)
le.fit(list(meta_df.iloc[:,0]))
y_raw = list(map(lambda x: str(x), list(data_df.join(meta_df).loc[:,'tumorType']))) 
y = le.transform(y_raw)

X = np.array(data_df)
# NOTE convert NaN to 0


pca = PCA()
pca.fit(X)
X_new = pca.transform(X)

def shrink_label(label_str):
  rv = None
  if len(label_str) > 30:
    words = label_str.split()
    rv = "".join(map(lambda x: x[0], words))
  else:
    rv = label_str
  return rv

for i in range(len(le.classes_)):
  ind = (y == i)
  xs = X_new[ind,0]
  ys = X_new[ind,1]
  plt.scatter(xs, ys, label=shrink_label(le.classes_[i]))
plt.legend(loc='lower center', borderaxespad=0., ncol=2, mode='expand')
plt.title("PCA Variance Explained = {:1.2f}".format(np.sum(pca.explained_variance_ratio_[:2])))
plt.xlabel("PCA Dimension 1: {:1.2f}".format(pca.explained_variance_ratio_[0]))
plt.ylabel("PCA Dimension 2: {:1.2f}".format(pca.explained_variance_ratio_[1]))
plt.tight_layout()
plt.savefig(os.path.join(args.outdir, 'scatter.png'))

# TODO or hierarchical clustering?
#kmeans = KMeans(n_clusters=6).fit(data_df)

# Interpret data matrix as a soft clustering, assign each sample to the latent cluster with
# the highest loading
X_clust = np.argmax(np.array(X), axis=1)

# Associate each latent cluster to the tumor type 
# Note that adjusted_rand_score does not care about the label as long as the samples are assigned to the same cluster
# In [40]: y_true                                            
# Out[40]: array([1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3])
# 
# In [41]: y_other                                           
# Out[41]: array([2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3, 3, 3])
# 
# In [42]: adjusted_rand_score(y_true, y_other)              
# Out[42]: 1.0 # perfect score
score = adjusted_rand_score(X_clust, y)
print("adjusted_rand_score = {}".format(score))

# do correlation analysis:
# within a tumor type, the samples should be more correlated to each other than they are to other tumor samples
# visualize with box plots of intra-tumor pairwise correlations and inter-tumor pairwise correlation
y_set = le.transform(le.classes_)

# intra-tumor correlation: map tumor label to correlation coefficients
intra_tumor_corr_coefs = {}
for y_i in y_set:
  X_i = X[y == y_i,:]
  obs_i, feat_i = X_i.shape

  cov = np.corrcoef(X_i)
  coefs = []
  for i in range(obs_i):
    for j in range(i+1, obs_i):
      coef = cov[i,j]
      coefs.append(coef)

  intra_tumor_corr_coefs[y_i] = coefs

# inter-tumor correlation: map pairs to list of correlation coefficients
inter_tumor_corr_coefs = {}
for y_i, y_j in it.combinations(y_set, 2):
  X_i = X[y == y_i,:]
  X_j = X[y == y_j,:]

  obs_i, feat_i = X_i.shape
  obs_j, feat_j = X_j.shape

  # concatentate rows
  X_icj = np.concatenate((X_i, X_j), axis=0)
  cov = np.corrcoef(X_icj)

  # collect inter-tumor correlation coefficients
  coefs = []
  for k, l in it.product(range(obs_i), range(obs_j)):
    coef = cov[k,l]
    coefs.append(coef)

  inter_tumor_corr_coefs[(y_i, y_j)] = coefs

# box plots
# intra-tumor
classes = []
data = []
for k,v in intra_tumor_corr_coefs.items():
  classes.append(k)
  data.append(v)
plt.clf()
plt.title('Intra-Tumor Feature Correlation')
plt.boxplot(data)
ax = plt.gca()
ax.set_xticklabels(list(map(lambda x: class_labels_map.get(x, x), le.inverse_transform(classes))), rotation=90)
plt.xlabel('Tumor Type')
plt.ylabel('Pearson Correlation Coefficient')
plt.tight_layout()
plt.savefig(os.path.join(args.outdir, 'intra_tumor_correlation.png'))

# inter-tumor
classes = []
data = []
for k,v in inter_tumor_corr_coefs.items():
  classes.append(k)
  data.append(v)
plt.clf()
plt.title('Inter-Tumor Feature Correlation')
plt.boxplot(data)
ax = plt.gca()
class_labels = []
for class_pair in classes:
  class_pair_label = list(map(lambda x: class_labels_map.get(x, x), le.inverse_transform(list(class_pair))))
  class_labels.append("-".join(class_pair_label))
ax.set_xticklabels(class_labels, rotation=90)
plt.xlabel('Tumor Type Pairs')
plt.ylabel('Pearson Correlation Coefficient')
plt.tight_layout()
plt.savefig(os.path.join(args.outdir, 'inter_tumor_corrlation.png'))

# hierarchical clustering
#import seaborn as sns
