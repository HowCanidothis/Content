/****************************************************************************
** Meta object code from reading C++ file 'propertiesview.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.9.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../../Work/PropertiesModule/propertiesview.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'propertiesview.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.9.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_PropertiesView_t {
    QByteArrayData data[3];
    char stringdata0[48];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_PropertiesView_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_PropertiesView_t qt_meta_stringdata_PropertiesView = {
    {
QT_MOC_LITERAL(0, 0, 14), // "PropertiesView"
QT_MOC_LITERAL(1, 15, 31), // "on_OpenWithTextEditor_triggered"
QT_MOC_LITERAL(2, 47, 0) // ""

    },
    "PropertiesView\0on_OpenWithTextEditor_triggered\0"
    ""
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_PropertiesView[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       1,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: name, argc, parameters, tag, flags
       1,    0,   19,    2, 0x08 /* Private */,

 // slots: parameters
    QMetaType::Void,

       0        // eod
};

void PropertiesView::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        PropertiesView *_t = static_cast<PropertiesView *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->on_OpenWithTextEditor_triggered(); break;
        default: ;
        }
    }
    Q_UNUSED(_a);
}

const QMetaObject PropertiesView::staticMetaObject = {
    { &QTreeView::staticMetaObject, qt_meta_stringdata_PropertiesView.data,
      qt_meta_data_PropertiesView,  qt_static_metacall, nullptr, nullptr}
};


const QMetaObject *PropertiesView::met