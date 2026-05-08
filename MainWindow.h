#pragma once

#include <QMainWindow>

QT_BEGIN_NAMESPACE
namespace Ui {
    class MainWindow;
}
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void selectSource();
    void selectOutput();
    void mergeImages();
    void updateStats();
    void updateModeUI();

private:
    Ui::MainWindow *ui;

    QString sourceFolder;
    QString outputFolder;

    void log(const QString& text);
};