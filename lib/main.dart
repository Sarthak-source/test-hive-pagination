import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/utils/hive_helper.dart';
import 'data/datasources/item_remote_data_source.dart';
import 'data/models/item_model.dart';
import 'data/repositories/item_repository_impl.dart';
import 'domain/usecases/get_paginated_items.dart';
import 'presentation/bloc/item_bloc.dart';
import 'presentation/pages/item_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ItemModelAdapter());
  await Hive.openBox(HiveHelper.cachedItemsBox);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final remoteDataSource = ItemRemoteDataSourceImpl();
    final hiveHelper = HiveHelper();
    final repository = ItemRepositoryImpl(
      remoteDataSource: remoteDataSource,
      hiveHelper: hiveHelper,
    );
    final getPaginatedItems = GetPaginatedItems(repository);

    return BlocProvider(
      create: (context) => ItemBloc(getPaginatedItems: getPaginatedItems),
      child: MaterialApp(
        title: 'Paginated Items App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const ItemListPage(),
      ),
    );
  }
}


