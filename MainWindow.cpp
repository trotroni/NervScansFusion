#include "MainWindow.h"
#include "ui_MainWindow.h"

#include <QFileDialog>
#include <QDir>
#include <QImage>
#include <QPainter>
#include <QMessageBox>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    updateModeUI();
    ui->labelImageCount

    connect(ui->btnSource, &QPushButton::clicked,
            this, &MainWindow::selectSource);

    connect(ui->btnOutput, &QPushButton::clicked,
            this, &MainWindow::selectOutput);

    connect(ui->btnMerge, &QPushButton::clicked,
            this, &MainWindow::mergeImages);

    connect(ui->spinPages,
        QOverload<int>::of(&QSpinBox::valueChanged),
        this,
        [this](int)
    {
        updateStats();
    });

    connect(ui->comboMode,
        QOverload<int>::of(&QComboBox::currentIndexChanged),
        this,
        &MainWindow::updateModeUI);
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::log(const QString& text)
{
    ui->logText->append(text);
}

void MainWindow::updateStats()
{
    if (sourceFolder.isEmpty())
        return;

    QDir dir(sourceFolder);

    QStringList filters;
    filters << "*.png" << "*.jpg" << "*.jpeg" << "*.webp";

    QFileInfoList files = dir.entryInfoList(filters, QDir::Files, QDir::Name);

    int mode = ui->comboMode->currentIndex();
    int spinValue = ui->spinPages->value();

    int groupSize = spinValue;

    if (mode == 1)
    {
        int nbFinalPages = spinValue;
        groupSize = qMax(1, (count + nbFinalPages - 1) / nbFinalPages);
    }

    // ---- MODE ----
    int mode = ui->comboMode->currentIndex();
    int groupSize = ui->spinPages->value();

    if (mode == 1)
    {
        int nbFinalPages = groupSize;
        groupSize = qMax(1, count / nbFinalPages);
    }

    int outputPages = (count + groupSize - 1) / groupSize;

    ui->labelOutputPages->setText(
        QString("Pages générées : %1").arg(outputPages)
    );

    // ---- STATS IMAGE ----
    long long totalWidth = 0;
    long long totalHeight = 0;

    int maxWidth = 0;

    for (const QFileInfo& file : files)
    {
        QImage img(file.absoluteFilePath());
        if (img.isNull()) continue;

        totalWidth += img.width();
        totalHeight += img.height();
        maxWidth = qMax(maxWidth, img.width());
    }

    int avgWidth = totalWidth / count;
    int avgHeight = totalHeight / count;

    ui->labelImageCount->setText(QString("Images : %1").arg(count));
    ui->labelAverageSize->setText(QString("Moyenne : %1x%2 px").arg(avgWidth).arg(avgHeight));

    int estimatedHeight = totalHeight / groupSize;

    ui->labelEstimatedOutput->setText(
        QString("Sortie estimée : %1x%2 px")
            .arg(maxWidth)
            .arg(estimatedHeight)
    );
}

void MainWindow::selectSource()
{
    sourceFolder = QFileDialog::getExistingDirectory(this);

    updateStats();

    ui->labelSource->setText(sourceFolder);
}

void MainWindow::selectOutput()
{
    outputFolder = QFileDialog::getExistingDirectory(this);

    ui->labelOutput->setText(outputFolder);
}

void MainWindow::updateModeUI()
{
    int mode = ui->comboMode->currentIndex();

    if (mode == 0)
        ui->spinPages->setSuffix(" img/page");
    else
        ui->spinPages->setSuffix(" pages finales");
}

void MainWindow::mergeImages()
{
    int mode = ui->comboMode->currentIndex();

    int groupSize = 1;

    if (mode == 0)
    {
        // mode classique
        groupSize = ui->spinPages->value();
    }
    else
    {
        // mode pages finales
        int totalImages = 0;

        QDir dir(sourceFolder);
        QStringList filters;
        filters << "*.png" << "*.jpg" << "*.jpeg" << "*.webp";

        totalImages = dir.entryInfoList(filters).size();

        int nbFinalPages = ui->spinPages->value();

        if (nbFinalPages <= 0)
            nbFinalPages = 1;

        groupSize = qMax(1, totalImages / nbFinalPages);
    }
    if (sourceFolder.isEmpty() || outputFolder.isEmpty())
    {
        QMessageBox::warning(this, "Erreur", "Dossiers manquants");
        return;
    }

    QDir dir(sourceFolder);

    QStringList filters;
    filters << "*.png" << "*.jpg" << "*.jpeg" << "*.webp";

    QFileInfoList files = dir.entryInfoList(
        filters,
        QDir::Files,
        QDir::Name
    );

    //int pagesPerMerge = ui->spinPages->value();
    int pagesPerMerge = groupSize;

    QList<QFileInfoList> groups;

    for (int i = 0; i < files.size(); i += pagesPerMerge)
    {
        QFileInfoList group;

        for (int j = i; j < i + pagesPerMerge && j < files.size(); ++j)
        {
            group.append(files[j]);
        }

        groups.append(group);
    }

    ui->progressBar->setMaximum(groups.size());

    for (int g = 0; g < groups.size(); ++g)
    {
        QFileInfoList group = groups[g];

        QList<QImage> images;

        int totalHeight = 0;
        int maxWidth = 0;

        for (const QFileInfo& file : group)
        {
            QImage img(file.absoluteFilePath());

            if (img.isNull())
            {
                log("Erreur : " + file.fileName());
                continue;
            }

            images.append(img);

            totalHeight += img.height();

            maxWidth = qMax(maxWidth, img.width());
        }

        QImage canvas(maxWidth, totalHeight, QImage::Format_ARGB32);
        canvas.fill(Qt::transparent);

        QPainter painter(&canvas);

        int y = 0;

        for (const QImage& img : images)
        {
            painter.drawImage(0, y, img);

            y += img.height();
        }

        painter.end();

        QString outputName =
            QString("page_fusion_%1.png")
            .arg(g + 1, 3, 10, QChar('0'));

        QString outputPath =
            QDir(outputFolder).filePath(outputName);

        canvas.save(outputPath, "PNG", 100);

        log("✓ " + outputName);

        ui->progressBar->setValue(g + 1);
    }

    QMessageBox::information(this, "Succès", "Fusion terminée");
}