rcnn_exp_cache_features('train');   % chunk1
rcnn_exp_cache_features('val');     % chunk2
rcnn_exp_cache_features('test_1');  % chunk3
rcnn_exp_cache_features('test_2');  % chunk4
test_results = rcnn_exp_train_and_test()
